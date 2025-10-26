# Contributing to Google Cloud Kit

Спасибо за интерес к развитию Google Cloud Kit! Мы приветствуем вклад сообщества.

## 🎯 Как внести вклад

### Сообщить об ошибке

1. Проверьте [Issues](https://github.com/vapor-community/google-cloud/issues), возможно проблема уже известна
2. Создайте новый Issue с описанием:
   - Версия пакета
   - Swift версия
   - Платформа (macOS/Linux/iOS)
   - Минимальный воспроизводимый пример
   - Ожидаемое и фактическое поведение

### Предложить улучшение

1. Создайте Issue с описанием предложения
2. Обсудите подход с maintainers
3. После одобрения создайте Pull Request

### Добавить новый функционал

1. Создайте Issue для обсуждения
2. Получите одобрение от maintainers
3. Реализуйте согласно стандартам проекта
4. Добавьте тесты
5. Обновите документацию
6. Создайте Pull Request

## 📝 Стандарты кода

### Стиль кода

- Следуйте [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Используйте async/await вместо callbacks
- Все публичные API должны быть документированы
- Используйте actors для shared mutable state

### Структура кода

```
ModuleName/
├── Sources/
│   ├── API/              # Протоколы и реализации API
│   ├── Models/           # Модели данных
│   ├── ModuleClient.swift    # Главный клиент
│   ├── ModuleRequest.swift   # HTTP запросы
│   ├── ModuleConfig.swift    # Конфигурация
│   ├── ModuleError.swift     # Ошибки
│   └── ModuleScope.swift     # OAuth scopes
└── Tests/
    └── ModuleTests.swift
```

### Аутентификация

Все модули должны:
- Использовать `AccessTokenProvider` для получения токенов
- Поддерживать все типы credentials (Service Account, GCloud, Compute Engine)
- Кэшировать токены с appropriate expiration buffer
- Быть thread-safe (используйте actors)

### Пример нового модуля

```swift
import CloudCore
import AsyncHTTPClient

public struct GoogleCloudNewServiceClient {
    public var api: NewServiceAPI
    let request: GoogleCloudNewServiceRequest
    
    public init(strategy: CredentialsLoadingStrategy,
                client: HTTPClient,
                scope: [GoogleCloudNewServiceScope]) async throws {
        let resolvedCredentials = try await CredentialsResolver.resolveCredentials(strategy: strategy)
        
        switch resolvedCredentials {
        case .serviceAccount(let creds):
            let provider = ServiceAccountCredentialsProvider(client: client, credentials: creds, scope: scope)
            request = .init(tokenProvider: provider, client: client, project: creds.projectId)
        // ... другие случаи
        }
        
        api = GoogleCloudNewServiceAPI(request: request, endpoint: "https://...")
    }
}
```

## 🧪 Тестирование

### Обязательно

- Добавьте unit тесты для нового функционала
- Убедитесь что существующие тесты проходят: `swift test`
- Проверьте сборку: `swift build`

### Желательно

- Integration тесты с mock servers
- Тесты для edge cases
- Тесты для error handling

### Запуск тестов

```bash
# Все тесты
swift test

# Конкретный модуль
swift test --filter StorageTests

# С verbose output
swift test --verbose
```

## 📚 Документация

### Обязательно

- Документируйте все публичные API с помощью `///`
- Добавьте примеры использования в README модуля
- Обновите главный README.md если добавлен новый модуль

### Формат документации

```swift
/// Краткое описание метода
///
/// Детальное описание (опционально)
///
/// - Parameters:
///   - bucket: Название bucket
///   - object: Название объекта
/// - Returns: Метаданные загруженного объекта
/// - Throws: `CloudStorageAPIError` если операция не удалась
public func upload(bucket: String, object: String) async throws -> StorageObject {
    // ...
}
```

## 🔄 Pull Request Process

### 1. Подготовка

```bash
# Fork репозиторий
# Clone вашего fork
git clone https://github.com/YOUR_USERNAME/google-cloud.git
cd google-cloud

# Создайте feature branch
git checkout -b feature/my-new-feature
```

### 2. Разработка

```bash
# Внесите изменения
# Добавьте тесты
# Обновите документацию

# Проверьте
swift build
swift test

# Commit
git add .
git commit -m "feat: add new feature"
```

### 3. Pull Request

- Опишите что изменилось и зачем
- Ссылайтесь на related issues
- Убедитесь что CI проходит
- Ответьте на комментарии reviewers

### Формат commit messages

Используйте [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: добавить новый API endpoint
fix: исправить token caching
docs: обновить README
refactor: упростить error handling
test: добавить тесты для новой функции
chore: обновить зависимости
```

## 🏗️ Архитектурные принципы

### 1. Модульность

Каждый сервис - отдельный модуль с минимальными зависимостями:
- Core - базовая аутентификация
- Сервисные модули зависят только от Core
- Vapor обертки опциональны

### 2. Async/Await first

- Все публичные API используют async/await
- Никаких EventLoopFuture в публичном API
- Callbacks только для совместимости с legacy кодом

### 3. Type Safety

- Строгая типизация для всех API
- Используйте enums для фиксированных значений
- Codable для всех моделей данных
- Sendable conformance где необходимо

### 4. Безопасность

- Никогда не логируйте credentials или токены
- Используйте HTTPS для всех запросов
- Proper timeout настройки
- Валидация входных данных

## 🐛 Отладка

### Логирование

```swift
import Logging

let logger = Logger(label: "google-cloud.storage")
logger.info("Uploading file", metadata: ["bucket": .string(bucket)])
```

### Тестирование с реальным API

```bash
# Установите credentials
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/test-service-account.json
export GOOGLE_PROJECT_ID=your-test-project

# Запустите ваш тест
swift run YourTest
```

## 📖 Ресурсы

### Официальная документация Google

- [Google Cloud Storage API](https://cloud.google.com/storage/docs/json_api/v1)
- [Google Cloud Datastore API](https://cloud.google.com/datastore/docs/reference/data/rest)
- [Authentication Spec (AIP-4112)](https://google.aip.dev/auth/4112)

### Swift ресурсы

- [Swift.org](https://swift.org)
- [Swift Evolution](https://github.com/apple/swift-evolution)
- [Vapor Documentation](https://docs.vapor.codes)

## ❓ Вопросы

Если у вас есть вопросы:
1. Проверьте [документацию](./docs/)
2. Поищите в [Issues](https://github.com/vapor-community/google-cloud/issues)
3. Создайте новый Issue с тегом `question`

## 📄 Лицензия

Весь вклад лицензируется под MIT License. См. [LICENSE](./LICENSE).

---

**Спасибо за ваш вклад!** 🎉

