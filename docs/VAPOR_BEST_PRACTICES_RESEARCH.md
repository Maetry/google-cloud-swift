# Vapor 4.x Best Practices для интеграции сервисов

## 🔍 Исследование актуальных паттернов

### Best Practices Vapor 4.x (2024-2025)

#### 1. **Provider Pattern**
Vapor рекомендует использовать Provider для регистрации сервисов:

```swift
public struct GoogleCloudProvider: Provider {
    public func register(_ app: Application) throws {
        // Регистрация конфигурации
        app.storage[GoogleCloudConfigurationKey.self] = configuration
    }
}
```

#### 2. **LifecycleHandler для Async инициализации**
```swift
public struct GoogleCloudLifecycle: LifecycleHandler {
    public func didBoot(_ app: Application) throws {
        // Async инициализация БЕЗ блокировки
        Task {
            try await initializeClients(app)
        }
    }
    
    public func shutdown(_ app: Application) {
        // Cleanup
    }
}
```

#### 3. **Application.Storage для кэширования**
```swift
extension Application {
    struct GoogleCloudKey: StorageKey {
        typealias Value = GoogleCloudClients
    }
    
    var googleCloudClients: GoogleCloudClients? {
        get { storage[GoogleCloudKey.self] }
        set { storage[GoogleCloudKey.self] = newValue }
    }
}
```

#### 4. **Избегать блокирующих вызовов**
❌ **ПЛОХО (текущая реализация):**
```swift
var client: GoogleCloudStorageClient {
    let semaphore = DispatchSemaphore(value: 0)  // ❌ Блокирует поток!
    Task {
        result = try await GoogleCloudStorageClient(...)
        semaphore.signal()
    }
    semaphore.wait()  // ❌ БЛОКИРОВКА!
    return result!
}
```

✅ **ХОРОШО:**
```swift
var storage: GoogleCloudStorageClient {
    get throws {
        guard let client = app.storage[StorageClientKey.self] else {
            throw GoogleCloudError.clientNotInitialized
        }
        return client
    }
}
```

#### 5. **Locks для thread-safety**
```swift
struct CloudStorageHTTPClientKey: StorageKey, LockKey {
    typealias Value = HTTPClient
}

var http: HTTPClient {
    if let existing = application.storage[CloudStorageHTTPClientKey.self] {
        return existing
    } else {
        let lock = application.locks.lock(for: CloudStorageHTTPClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        // Double-check после получения lock
        if let existing = application.storage[CloudStorageHTTPClientKey.self] {
            return existing
        }
        let new = HTTPClient(...)
        application.storage.set(CloudStorageHTTPClientKey.self, to: new) { ... }
        return new
    }
}
```

## 📊 Проблемы текущей реализации

### ❌ Проблема 1: Блокирующий semaphore в async контексте
```swift
// VaporIntegration/Cloud*/GoogleCloud*API.swift
public var client: GoogleCloudStorageClient {
    let semaphore = DispatchSemaphore(value: 0)
    // ...
    semaphore.wait()  // ❌ Блокирует thread pool!
}
```

**Почему плохо:**
- Блокирует потоки Vapor
- На Cloud Run может вызвать deadlock
- Не соответствует Swift Concurrency best practices

### ❌ Проблема 2: Нет graceful error handling
```swift
if let error = error {
    fatalError("\(error.localizedDescription)")  // ❌ Crash всего приложения!
}
```

**Почему плохо:**
- Crash вместо error throwing
- Нет возможности recovery
- Плохой UX

### ❌ Проблема 3: Множественные инициализации
```swift
extension Request {
    public var gcs: GoogleCloudStorageClient {
        if let existing = application.storage[GoogleCloudStorageKey.self] {
            return existing
        } else {
            let new = ...client  // ← Каждый request может создать новый клиент
        }
    }
}
```

**Почему плохо:**
- Race condition возможен
- Множественные OAuth токены
- Неэффективно

## ✅ Рекомендуемое решение

### Подход 1: Provider + LifecycleHandler (BEST для Cloud Run)

```swift
// 1. Provider для регистрации
public struct GoogleCloudProvider {
    let configuration: GoogleCloudCredentialsConfiguration
    
    public init(configuration: GoogleCloudCredentialsConfiguration) {
        self.configuration = configuration
    }
    
    public func register(_ app: Application) {
        app.googleCloud.configuration = configuration
    }
}

// 2. LifecycleHandler для async init
struct GoogleCloudLifecycle: LifecycleHandler {
    func didBoot(_ app: Application) throws {
        Task.detached {
            await app.googleCloud.initialize()
        }
    }
    
    func shutdown(_ app: Application) {
        app.googleCloud.clients = nil
    }
}

// 3. Storage с pre-initialized клиентами
public struct GoogleCloudClients {
    public let storage: GoogleCloudStorageClient
    public let datastore: GoogleCloudDatastoreClient
    // ...
}

extension Application.GoogleCloudPlatform {
    var clients: GoogleCloudClients? {
        get { application.storage[ClientsKey.self] }
        set { application.storage[ClientsKey.self] = newValue }
    }
    
    func initialize() async {
        // Async инициализация всех клиентов
    }
}

// 4. Request extension с error handling
extension Request {
    var gcs: GoogleCloudStorageClient {
        get throws {
            guard let clients = application.googleCloud.clients else {
                throw Abort(.serviceUnavailable, 
                    reason: "Google Cloud not initialized. Add GoogleCloudLifecycle to app.lifecycle")
            }
            return clients.storage
        }
    }
}
```

### Подход 2: Lazy + Opti onal (BEST для редких операций)

```swift
// Простая ленивая инициализация с optional
extension Application.GoogleCloudPlatform {
    private struct StorageClientKey: StorageKey, LockKey {
        typealias Value = GoogleCloudStorageClient
    }
    
    func getOrCreateStorageClient() async throws -> GoogleCloudStorageClient {
        if let existing = application.storage[StorageClientKey.self] {
            return existing
        }
        
        // Double-checked locking pattern
        let lock = application.locks.lock(for: StorageClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = application.storage[StorageClientKey.self] {
            return existing
        }
        
        // Создаем клиент
        let client = try await GoogleCloudStorageClient(
            strategy: credentials.strategy,
            client: httpClient,
            scope: storageConfiguration.scope
        )
        
        application.storage[StorageClientKey.self] = client
        return client
    }
}

extension Request {
    var gcs: GoogleCloudStorageClient {
        get async throws {
            try await application.googleCloud.getOrCreateStorageClient()
        }
    }
}
```

## 🎯 Рекомендация

Для вашего случая (аватарки ~5% запросов) лучший подход - **Подход 2: Lazy + Optional**

Преимущества:
- ✅ Нет блокирующих вызовов
- ✅ Async/await нативно
- ✅ Thread-safe с locks
- ✅ Клиент создается только при необходимости
- ✅ Кэшируется для последующих запросов
- ✅ Graceful error handling

