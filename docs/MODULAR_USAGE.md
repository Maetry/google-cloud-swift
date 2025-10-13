# Модульное использование Google Cloud Kit

**Версия:** 2.0.0  
**Особенность:** Каждый сервис - отдельный продукт. Подключайте только то, что нужно!

## 🎯 Концепция модульности

Вы можете подключить:
- ✅ **Только Storage** - без Datastore, PubSub и т.д.
- ✅ **Только SecretManager** - без остальных сервисов
- ✅ **Storage + Datastore** - только нужные
- ✅ **Все сервисы** - если нужно все

## 📦 Доступные продукты

### Без Vapor (чистые сервисы)

```swift
// Только то, что нужно!
.product(name: "GoogleCloudStorage", package: "google-cloud")
.product(name: "GoogleCloudDatastore", package: "google-cloud")
.product(name: "GoogleCloudPubSub", package: "google-cloud")
.product(name: "GoogleCloudSecretManager", package: "google-cloud")
.product(name: "GoogleCloudTranslation", package: "google-cloud")
.product(name: "GoogleCloudIAMServiceAccountCredentials", package: "google-cloud")

// Core отдельно (если нужна только аутентификация)
.product(name: "GoogleCloudCore", package: "google-cloud")

// Все вместе
.product(name: "GoogleCloudKit", package: "google-cloud")
```

### С Vapor (модульные обертки)

```swift
// Базовый модуль (credentials, configuration)
.product(name: "VaporGoogleCloudCore", package: "google-cloud")

// Отдельные сервисы (каждый включает Core автоматически)
.product(name: "VaporGoogleCloudStorage", package: "google-cloud")
.product(name: "VaporGoogleCloudDatastore", package: "google-cloud")
.product(name: "VaporGoogleCloudPubSub", package: "google-cloud")
.product(name: "VaporGoogleCloudSecretManager", package: "google-cloud")
.product(name: "VaporGoogleCloudTranslation", package: "google-cloud")
```

---

## 🎯 Примеры использования

### Пример 1: Только Storage (ваш случай!)

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.117.0"),
    .package(url: "https://github.com/vapor-community/google-cloud.git", from: "2.0.0")
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "VaporGoogleCloudStorage", package: "google-cloud"),  // ← Только Storage!
    ])
]
```

**Что подтянется:**
```
VaporGoogleCloudStorage
├── VaporGoogleCloudCore  (автоматически)
│   └── Core              (автоматически)
└── Storage               (автоматически)
```

**Что НЕ подтянется:**
- ❌ Datastore
- ❌ PubSub
- ❌ SecretManager
- ❌ Translation
- ❌ IAMServiceAccountCredentials

**Размер зависимостей:** ~30% от полного пакета

---

### Пример 2: Storage + SecretManager

```swift
// Package.swift
targets: [
    .target(name: "App", dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "VaporGoogleCloudStorage", package: "google-cloud"),
        .product(name: "VaporGoogleCloudSecretManager", package: "google-cloud"),
    ])
]
```

**Что подтянется:**
- ✅ Core (один раз)
- ✅ Storage
- ✅ SecretManager

**Что НЕ подтянется:**
- ❌ Datastore, PubSub, Translation

**Код:**
```swift
// configure.swift
import VaporGoogleCloudStorage
import VaporGoogleCloudSecretManager

app.googleCloud.credentials = GoogleCloudCredentialsConfiguration()
app.googleCloud.storageConfiguration = .default()

// routes.swift
let storage = try await req.googleCloudStorage()
// SecretManager пока не имеет req расширения,
// используйте напрямую GoogleCloudSecretManagerClient
```

---

### Пример 3: Все сервисы

```swift
// Package.swift
targets: [
    .target(name: "App", dependencies: [
        .product(name: "Vapor", package: "vapor"),
        // Все Vapor обертки
        .product(name: "VaporGoogleCloudStorage", package: "google-cloud"),
        .product(name: "VaporGoogleCloudDatastore", package: "google-cloud"),
        .product(name: "VaporGoogleCloudPubSub", package: "google-cloud"),
        .product(name: "VaporGoogleCloudSecretManager", package: "google-cloud"),
        .product(name: "VaporGoogleCloudTranslation", package: "google-cloud"),
    ])
]
```

---

### Пример 4: Без Vapor (минимально)

```swift
// Package.swift
targets: [
    .target(name: "MyApp", dependencies: [
        .product(name: "GoogleCloudStorage", package: "google-cloud"),  // Только Storage
        .product(name: "AsyncHTTPClient", package: "async-http-client"),
    ])
]
```

**Код:**
```swift
import GoogleCloudStorage
import AsyncHTTPClient

let client = HTTPClient(eventLoopGroupProvider: .singleton)

let storage = try await GoogleCloudStorageClient(
    strategy: .environment,
    client: client,
    scope: [.fullControl]
)

let buckets = try await storage.buckets.list()
```

**Что подтянется:**
- ✅ Core
- ✅ Storage

**Что НЕ подтянется:** Все остальные сервисы + Vapor

---

## 📊 Сравнение размеров

| Конфигурация | Модулей | Примерный размер |
|--------------|---------|------------------|
| Только Storage | Core + Storage | ~30% |
| Storage + SecretManager | Core + 2 сервиса | ~40% |
| Все сервисы | Core + 6 сервисов | 100% |
| Без Vapor | Core + сервисы | -20% (нет Vapor) |
| С Vapor | + VaporGoogleCloudCore | +5% |

---

## 🎯 Рекомендации

### Для вашего случая (аватарки):

```swift
// Package.swift - МИНИМУМ
.product(name: "VaporGoogleCloudStorage", package: "google-cloud")

// Только:
// - Core (аутентификация)
// - Storage (загрузка файлов)
// - VaporGoogleCloudCore (Vapor расширения)
```

**Результат:**
- ✅ Минимальные зависимости
- ✅ Быстрая компиляция
- ✅ Меньше кода для линковки

---

### Если позже понадобится другой сервис:

Просто добавьте продукт в Package.swift:

```swift
// Было
.product(name: "VaporGoogleCloudStorage", package: "google-cloud")

// Добавили SecretManager
.product(name: "VaporGoogleCloudStorage", package: "google-cloud"),
.product(name: "VaporGoogleCloudSecretManager", package: "google-cloud"),  // ← Новое!
```

**Никаких других изменений!** Core переиспользуется.

---

## ✅ Итог

```
╔══════════════════════════════════════════════════╗
║                                                  ║
║  ✅ ПОЛНАЯ МОДУЛЬНОСТЬ                            ║
║                                                  ║
║  Подключайте ТОЛЬКО то, что нужно:               ║
║                                                  ║
║  • Только Storage        → 30% зависимостей      ║
║  • Storage + Secrets     → 40% зависимостей      ║
║  • Все сервисы           → 100% зависимостей     ║
║                                                  ║
║  Core автоматически включается всегда            ║
║  Vapor интеграция опциональна                    ║
║                                                  ║
╚══════════════════════════════════════════════════╝
```

**Подключайте только то, что используете!** 🎯

