# GoogleCloudKit

![Swift](http://img.shields.io/badge/swift-5.7-brightgreen.svg)
![Platforms](http://img.shields.io/badge/platforms-macOS%20%7C%20iOS-brightgreen.svg)
![JWTKit](http://img.shields.io/badge/JWTKit-5.2.0-blue.svg)
![Vapor](http://img.shields.io/badge/Vapor-4.117-purple.svg)

Модульный Swift пакет для работы с Google Cloud Platform APIs с поддержкой async/await и Vapor.

## 🎯 Особенности

- ✅ Современный **async/await** API
- ✅ **Модульная архитектура** - подключайте только нужное!
- ✅ Опциональная интеграция с **Vapor 4.117+**
- ✅ Actors для потокобезопасности
- ✅ **JWTKit 5.2.0** с Swift Crypto
- ✅ **Без блокирующих вызовов** в Vapor
- ✅ Проверено с реальными Service Account

## 📦 Поддерживаемые сервисы

- ✅ **Cloud Storage** - хранение файлов
- ✅ **Cloud Datastore** - NoSQL БД  
- ✅ **Cloud Pub/Sub** - обмен сообщениями
- ✅ **Secret Manager** - управление секретами
- ✅ **Cloud Translation** - перевод текста
- ✅ **IAM Service Account Credentials** - подписание JWT

## 🚀 Установка (модульная!)

### Только Storage (для аватарок, файлов)

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/vapor-community/google-cloud.git", from: "2.0.0")
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "VaporGoogleCloudStorage", package: "google-cloud"),  // ← Только Storage!
    ])
]
```

### Storage + SecretManager

```swift
targets: [
    .target(name: "App", dependencies: [
        .product(name: "VaporGoogleCloudStorage", package: "google-cloud"),
        .product(name: "VaporGoogleCloudSecretManager", package: "google-cloud"),
    ])
]
```

### Все сервисы

```swift
.product(name: "GoogleCloudKit", package: "google-cloud")  // Все без Vapor
// ИЛИ с Vapor:
.product(name: "VaporGoogleCloudStorage", package: "google-cloud"),
.product(name: "VaporGoogleCloudDatastore", package: "google-cloud"),
// ... и т.д.
```

## 📝 Использование

### С Vapor (рекомендуется для Cloud Run)

```swift
// configure.swift
import Vapor
import VaporGoogleCloudStorage  // ← Только Storage

public func configure(_ app: Application) throws {
    // Credentials (для всех сервисов)
    app.googleCloud.credentials = GoogleCloudCredentialsConfiguration()
    
    // Storage конфигурация
    app.googleCloud.storageConfiguration = .default()
    
    // ОПЦИОНАЛЬНО: Pre-warm для лучшей производительности
    // app.lifecycle.use(GoogleCloudStorageLifecycle())
}

// routes.swift  
app.post("upload") { req async throws -> String in
    // Async метод - БЕЗ блокировки потоков!
    let storage = try await req.googleCloudStorage()
    
    let object = try await storage.object.createSimpleUpload(
        bucket: "my-bucket",
        data: req.body.data ?? Data(),
        name: "file.jpg",
        contentType: "image/jpeg"
    )
    
    return "Uploaded"
}
```

### Без Vapor

```swift
import GoogleCloudStorage  // ← Только Storage (без Vapor!)
import AsyncHTTPClient

let client = HTTPClient(eventLoopGroupProvider: .singleton)

let storage = try await GoogleCloudStorageClient(
    strategy: .environment,
    client: client,
    scope: [.fullControl]
)

let buckets = try await storage.buckets.list()
```

## ⚡ Две стратегии инициализации

### Стратегия 1: Ленивая (для редких операций) ⭐

```swift
// configure.swift - БЕЗ lifecycle
app.googleCloud.storageConfiguration = .default()

// routes.swift
let storage = try await req.googleCloudStorage()  // Создается при первом вызове
```

**Когда:** Storage используется редко (<20% запросов)  
**Плюсы:** Быстрый startup, не расходует ресурсы  
**Минусы:** Первый запрос +2-3 сек

### Стратегия 2: Pre-initialization (для частых операций)

```swift
// configure.swift - ДОБАВИТЬ lifecycle
app.googleCloud.storageConfiguration = .default()
app.lifecycle.use(GoogleCloudStorageLifecycle())  // ← Прогрев!

// routes.swift - ТОТ ЖЕ КОД
let storage = try await req.googleCloudStorage()  // Уже готов!
```

**Когда:** Storage используется часто (>30% запросов)  
**Плюсы:** Все запросы быстрые  
**Минусы:** +2-3 сек к startup (в фоне)

---

## 🔐 Аутентификация

### Cloud Run (автоматически)

```swift
app.googleCloud.credentials = GoogleCloudCredentialsConfiguration()
```

### Локально

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
```

## 📚 Документация

- **[Modular Usage](./docs/MODULAR_USAGE.md)** - этот файл
- **[Quick Start](./docs/QUICK_START_CLOUD_RUN.md)** - Cloud Run
- **[Vapor Integration](./docs/VAPOR_INTEGRATION_IMPROVED.md)** - детали
- **[All docs](./docs/)** - вся документация

## 🏗️ Структура

```
GoogleCloud/
├── Core/                  # Аутентификация (всегда нужен)
├── Services/             # 6 сервисов (выбирайте нужные)
├── VaporIntegration/     # Vapor обертки (опционально)
├── Tests/
├── Examples/
└── docs/
```

## 📊 Размеры зависимостей

| Что подключили | Что получили |
|----------------|--------------|
| VaporGoogleCloudStorage | Core + Storage (~30%) |
| VaporGoogleCloudStorage + VaporGoogleCloudSecretManager | Core + Storage + SecretManager (~40%) |
| GoogleCloudKit | Core + все 6 сервисов (100%, без Vapor) |
| Все Vapor продукты | Core + все 6 + Vapor обертки (100%) |

**Выбирайте только то, что нужно!** 🎯

---

**Готово к использованию!** 🚀
