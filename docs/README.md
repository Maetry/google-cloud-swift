# 📚 Документация Google Cloud Kit

Полная документация по использованию Google Cloud Kit с Vapor и без.

## 🚀 Быстрый старт

### Для новых пользователей

1. **[Quick Start for Cloud Run](./QUICK_START_CLOUD_RUN.md)** ⭐  
   Пошаговое руководство для деплоя Vapor приложения на Cloud Run с Google Cloud Storage

### Основные руководства

2. **[Modular Usage](./MODULAR_USAGE.md)** ⭐  
   Как подключить только нужные сервисы (Storage, SecretManager и т.д.)

3. **[Vapor Integration](./VAPOR_INTEGRATION_IMPROVED.md)** ⭐  
   Детали интеграции с Vapor 4.x, best practices, async API

4. **[Migration Guide](./MIGRATION.md)**  
   Миграция с google-cloud-kit-main на версию 2.0

5. **[Authentication Audit](./AUTHENTICATION_AUDIT.md)**  
   Детали аутентификации, проверка соответствия Google AIP стандартам

---

## 📖 Структура документации

### Руководства по использованию

| Документ | Описание | Для кого |
|----------|----------|----------|
| [Quick Start Cloud Run](./QUICK_START_CLOUD_RUN.md) | Деплой на Cloud Run | Новички, Production |
| [Modular Usage](./MODULAR_USAGE.md) | Подключение только нужных сервисов | Все |
| [Vapor Integration](./VAPOR_INTEGRATION_IMPROVED.md) | Best practices Vapor 4.x | Vapor разработчики |

### Технические детали

| Документ | Описание | Для кого |
|----------|----------|----------|
| [Migration Guide](./MIGRATION.md) | Миграция с v1 → v2 | Существующие пользователи |
| [Authentication Audit](./AUTHENTICATION_AUDIT.md) | Как работает аутентификация | Продвинутые |

---

## 🎯 Быстрые ответы

### Как подключить только Storage?

```swift
// Package.swift
.product(name: "VaporGoogleCloudStorage", package: "google-cloud")
```

Подробнее: [Modular Usage](./MODULAR_USAGE.md)

### Как работает аутентификация на Cloud Run?

```swift
// configure.swift
app.googleCloud.credentials = GoogleCloudCredentialsConfiguration()
// Metadata server работает автоматически!
```

Подробнее: [Quick Start Cloud Run](./QUICK_START_CLOUD_RUN.md#%EF%B8%8F-аутентификация-на-cloud-run)

### Нужен ли GoogleCloudStorageLifecycle?

**Нет, опционален!** Добавляйте только если нужен pre-warm.

Подробнее: [Vapor Integration](./VAPOR_INTEGRATION_IMPROVED.md#-vapor-integration-2-варианта)

### Как загрузить аватарку с публичным доступом?

```swift
let storage = try await req.googleCloudStorage()

try await storage.object.createSimpleUpload(
    bucket: "my-bucket",
    data: avatarData,
    name: "user-123/avatar.jpg"
)

try await storage.objectAccessControl.insert(
    bucket: "my-bucket",
    object: "user-123/avatar.jpg",
    entity: "allUsers",
    role: "READER"
)
```

Подробнее: [Quick Start Cloud Run](./QUICK_START_CLOUD_RUN.md#-пример-загрузка-аватарок)

---

## 📁 Остальная документация

### В корне проекта

- **[README.md](../README.md)** - Главная страница проекта
- **[CONTRIBUTING.md](../CONTRIBUTING.md)** - Как контрибьютить
- **[LICENSE](../LICENSE)** - MIT License

### В Examples/

- **[VaporAvatarUpload.swift](../Examples/VaporAvatarUpload.swift)** - Полный пример загрузки аватарок

---

## 🆘 Поддержка

Если не нашли ответ:
1. Проверьте [Quick Start](./QUICK_START_CLOUD_RUN.md)
2. Посмотрите [Examples](../Examples/)
3. Создайте issue на GitHub

---

**Все документы актуальны для версии 2.0.0** ✅
