# 📂 Структура проекта

**Версия:** 2.0.0  
**Финал:** 13 октября 2025

## 🎯 Идеальная единообразная структура

```
GoogleCloud/
├── README.md
├── LICENSE
├── Package.swift
├── CONTRIBUTING.md
├── STRUCTURE.md
├── .gitignore
│
├── Core/                     # 🔐 Аутентификация
│   ├── Sources/             # Основной код
│   └── Vapor/               # Vapor расширения
│
├── Services/                 # 📦 Все сервисы (единообразно!)
│   ├── Storage/
│   │   ├── Sources/         # Основной код
│   │   └── Vapor/           # Vapor расширения
│   ├── Datastore/
│   │   ├── Sources/
│   │   └── Vapor/
│   └── ... (все 6 так)
│
├── Tests/                    # 🧪 Unit тесты
├── Examples/                 # 🎨 Примеры
└── docs/                     # 📚 Документация
```

## ✅ Единообразная структура!

**Каждый модуль** (Core + все Services):
```
ModuleName/
├── Sources/     # Основной API код
└── Vapor/       # Vapor расширения (опционально)
```

### Core/

```
Core/
├── Sources/                  # Аутентификация (основной код)
│   ├── Credentials/
│   │   ├── CredentialLoadingStrategy.swift
│   │   ├── CredentialsType.swift
│   │   └── Providers/
│   │       ├── ServiceAccountCredentialsProvider.swift
│   │       ├── GcloudCredentialsProvider.swift
│   │       └── ComputeEngineCredentialsProvider.swift
│   ├── GoogleCloudAPIClient.swift
│   └── GoogleCloudError.swift
│
└── Vapor/                    # Vapor расширения для Core
    ├── GoogleCloudPlatform+Application.swift
    ├── GoogleCloudCredentialsConfiguration.swift
    └── GoogleCloudAPIConfiguration.swift
```

### Services/Storage/

```
Services/Storage/
├── Sources/                  # Storage API
│   ├── API/
│   │   ├── StorageBucketAPI.swift
│   │   ├── StorageObjectAPI.swift
│   │   └── ...
│   ├── Models/
│   ├── StorageClient.swift
│   └── StorageScope.swift
│
└── Vapor/                    # Vapor расширения для Storage
    ├── GoogleCloudPlatform+Storage.swift
    └── Storage+Vapor.swift
```

### Services/ (все остальные)

```
Services/
├── Datastore/
│   ├── Sources/
│   └── Vapor/
├── PubSub/
│   ├── Sources/
│   └── Vapor/
├── SecretManager/
│   ├── Sources/
│   └── Vapor/
├── Translation/
│   ├── Sources/
│   └── Vapor/
└── IAMServiceAccountCredentials/
    └── Sources/              # (без Vapor)
```

## 📦 Package.swift

### Core:

```swift
// Основной модуль (без Vapor)
.target(
    name: "Core",
    path: "Core/Sources/"
)

// Vapor расширения для Core
.target(
    name: "VaporGoogleCloudCore",
    dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .target(name: "Core"),
    ],
    path: "Core/Vapor/"  // ← Vapor расширения рядом!
)
```

### Storage:

```swift
// Основной модуль (без Vapor)
.target(
    name: "Storage",
    dependencies: [.target(name: "Core")],
    path: "Services/Storage/Sources/"
)

// Vapor расширения для Storage
.target(
    name: "VaporGoogleCloudStorage",
    dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .target(name: "Storage"),
        .target(name: "VaporGoogleCloudCore"),  // ← Зависит от Core/Vapor
    ],
    path: "Services/Storage/Vapor/"  // ← Vapor рядом!
)
```

## 🎯 Преимущества единообразия

| Аспект | Описание |
|--------|----------|
| **Единообразие** | Core и Services имеют одинаковую структуру |
| **Понятность** | `ModuleName/Sources/` - код, `ModuleName/Vapor/` - Vapor |
| **Модульность** | Vapor опционален для каждого модуля |
| **Масштабируемость** | Новый сервис = просто добавить `Sources/` + `Vapor/` |

## 📊 Подключение

### Только Core (аутентификация):

```swift
.product(name: "GoogleCloudCore", package: "google-cloud")
```
→ Подтянет: `Core/Sources/`

### Core + Vapor:

```swift
.product(name: "VaporGoogleCloudCore", package: "google-cloud")
```
→ Подтянет:
- `Core/Sources/` (аутентификация)
- `Core/Vapor/` (Vapor расширения для Core)

### Storage + Vapor:

```swift
.product(name: "VaporGoogleCloudStorage", package: "google-cloud")
```
→ Подтянет:
- `Core/Sources/` (аутентификация)
- `Core/Vapor/` (базовые Vapor расширения)
- `Services/Storage/Sources/` (Storage API)
- `Services/Storage/Vapor/` (Storage Vapor расширения)

## 📈 Сравнение подходов

### ❌ Было (разнесено):
```
Core/Sources/
VaporIntegration/Core/
Services/Storage/Sources/
VaporIntegration/Storage/
```

### ✅ Стало (единообразно):
```
Core/
├── Sources/
└── Vapor/

Services/Storage/
├── Sources/
└── Vapor/
```

## 🎨 Examples/

```
Examples/
├── README.md
├── VaporAvatarUpload.swift
├── RealStorageTest/
└── Scripts/
```

## 🧪 Tests/

```
Tests/
├── CoreTests/
├── StorageTests/
├── DatastoreTests/
├── TranslationTests/
└── PubSubTests/
```

## 📚 docs/

```
docs/
├── README.md
├── QUICK_START_CLOUD_RUN.md
├── MODULAR_USAGE.md
├── VAPOR_INTEGRATION_IMPROVED.md
├── MIGRATION.md
└── AUTHENTICATION_AUDIT.md
```

## 📊 Статистика

```
Директорий в корне:    9
├── Core               (Sources + Vapor)
├── Services           (6 сервисов, каждый Sources + Vapor)
├── Tests              (5 test targets)
├── Examples           (примеры)
└── docs               (документация)

Структура:             Единообразная!
Vapor файлов:          9
  - Core/Vapor/        3 файла
  - Services/*/Vapor/  6 файлов
```

## ✅ Итог

```
╔════════════════════════════════════════════════╗
║                                                ║
║  🎉 ИДЕАЛЬНАЯ ЕДИНООБРАЗНАЯ СТРУКТУРА           ║
║                                                ║
║  Каждый модуль (Core + Services):              ║
║  ModuleName/                                   ║
║    ├── Sources/   (основной код)               ║
║    └── Vapor/     (Vapor расширения)           ║
║                                                ║
║  ✅ Единообразно                                ║
║  ✅ Понятно                                     ║
║  ✅ Модульно                                    ║
║  ✅ Vapor опционален                            ║
║                                                ║
║  Все на своих местах! 🚀                       ║
║                                                ║
╚════════════════════════════════════════════════╝
```

**Core/Vapor/ - это Vapor расширения для Core, рядом с Sources!** ✅
