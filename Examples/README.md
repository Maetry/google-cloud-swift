# Примеры использования Google Cloud Kit

Практические примеры интеграции Google Cloud сервисов с Vapor и Swift.

## 📁 Структура

### Готовые примеры

- **[VaporAvatarUpload.swift](./VaporAvatarUpload.swift)** ⭐  
  Полный пример загрузки аватарок в Cloud Storage с Vapor:
  - Настройка configure.swift
  - Route handler для upload
  - Публичный доступ через ACL
  - Сохранение URL в базе данных
  - Удаление старых аватарок
  - Валидация файлов
  - Логирование

- **[RealStorageTest/](./RealStorageTest/)** 🧪  
  Executable тест для проверки аутентификации:
  - Загрузка credentials
  - Создание Storage клиента
  - Получение OAuth токена
  - Реальные API вызовы
  - Проверка кэширования токена
  - Проверка прав доступа

### Вспомогательные скрипты

- **[Scripts/AuthenticationVerification.swift](./Scripts/AuthenticationVerification.swift)**  
  Детальная проверка реализации аутентификации (информационный)

- **[Scripts/QuickAuthTest.swift](./Scripts/QuickAuthTest.swift)**  
  Быстрая проверка переменных окружения и credentials

- **[Scripts/TestAuthentication.swift](./Scripts/TestAuthentication.swift)**  
  Пошаговый тест аутентификации с комментариями

## 🚀 Использование

### Запуск RealStorageTest

```bash
# 1. Установите credentials
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

# 2. Запустите тест
cd /Users/vshevtsov/Works/Maetry/Forks/GoogleCloud
swift run RealStorageTest

# Или напрямую через swift
cd Examples/RealStorageTest
swift main.swift
```

### Запуск Quick Auth Test

```bash
swift Examples/Scripts/QuickAuthTest.swift
```

## 💡 Адаптация примеров

### Vapor Avatar Upload

Скопируйте код из `VaporAvatarUpload.swift` в ваш проект:

```swift
// 1. configure.swift - используйте ваши credentials
app.googleCloud.credentials = GoogleCloudCredentialsConfiguration(
    credentialsFile: "/path/to/your-service-account.json"
)

// 2. routes.swift - замените на ваш bucket
let bucket = "your-bucket-name"  // Вместо "my-app-avatars"

// 3. Адаптируйте User модель под вашу схему БД
```

## 📝 Создание своих примеров

Используйте шаблон:

```swift
import Foundation
import CloudCore
import Storage
import AsyncHTTPClient

@main
struct MyExample {
    static func main() async throws {
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        defer { try? httpClient.syncShutdown() }
        
        // Ваш код здесь
        let storage = try await GoogleCloudStorageClient(
            strategy: .environment,
            client: httpClient,
            scope: [.fullControl]
        )
        
        // Примеры операций
        let buckets = try await storage.buckets.list()
        print("Buckets: \(buckets.items?.count ?? 0)")
    }
}
```

## 🧪 Тестирование в вашем проекте

Для быстрой проверки интеграции:

```swift
// В вашем Vapor проекте добавьте тестовый route
app.get("test-storage") { req async throws -> String in
    let buckets = try await req.gcs.buckets.list(queryParameters: ["maxResults": "1"])
    return "✅ Storage works! Found \(buckets.items?.count ?? 0) buckets"
}
```

Откройте в браузере: `http://localhost:8080/test-storage`

## 🔗 Дополнительная документация

См. [docs/](../docs/) для полной документации по:
- Аутентификации
- Миграции
- API endpoints
- Best practices

