# Руководство по миграции на объединенный пакет

## Что изменилось

Пакет был полностью переписан с использованием современного **async/await** API и объединяет лучшее из двух версий:
- Современная архитектура аутентификации из `google-cloud-kit-async-await`
- Полная функциональность из `google-cloud-kit-main`

## Основные изменения

### 1. Async/Await вместо EventLoopFuture

**Было (старый API):**
```swift
let gcs = try GoogleCloudStorageClient(
    credentials: credentials,
    storageConfig: config,
    httpClient: client,
    eventLoop: eventLoop
)

gcs.buckets.list().map { buckets in
    print(buckets)
}
```

**Стало (новый API):**
```swift
let gcs = try await GoogleCloudStorageClient(
    strategy: .environment,
    client: httpClient,
    scope: [.fullControl]
)

let buckets = try await gcs.buckets.list()
print(buckets)
```

### 2. Новая система аутентификации

**CredentialsLoadingStrategy** заменяет старый `GoogleCloudCredentialsConfiguration`:

```swift
// Вариант 1: Из файла
.filePath("/path/to/service-account.json", .serviceAccount)

// Вариант 2: Из переменной окружения (путь к файлу)
.environment

// Вариант 3: JSON в переменной окружения
.environmentJSON

// Вариант 4: Metadata server на Compute Engine
.computeEngine(client: httpClient)
```

### 3. Без EventLoop

Новая архитектура не требует явного указания EventLoop. Все асинхронные операции автоматически выполняются в правильном контексте.

### 4. Улучшенный Datastore

**Новые возможности:**
- Поддержка `databaseId` для работы с несколькими базами данных
- Aggregation queries (COUNT, SUM, AVG)
- Улучшенная обработка отсутствующих entities

```swift
// Aggregation query
let count = try await datastore.project.runAggregationQuery(
    query: myQuery,
    aggregations: [.count(alias: "total")],
    partitionId: partitionId,
    databaseId: "my-database"
)

// Работа с конкретной базой данных
try await datastore.project.insert(entity, databaseId: "custom-db")
```

### 5. Vapor интеграция

Vapor обертки остались **обратно совместимы**, но теперь используют новый async/await Core:

```swift
// В configure.swift
app.googleCloud.credentials = GoogleCloudCredentialsConfiguration(
    project: "my-project",
    credentialsFile: "/path/to/service-account.json"
)

app.googleCloud.storage.configuration = .default()

// В route handlers
app.get("test") { req async throws -> String in
    let buckets = try await req.gcs.buckets.list()
    return "Found \(buckets.items?.count ?? 0) buckets"
}
```

**Важно:** Первый вызов `req.gcs` будет инициализировать клиент асинхронно внутри. Для лучшей производительности рекомендуется инициализировать клиентов при старте приложения.

## Новые модули

### IAMServiceAccountCredentials

Новый модуль для работы с IAM Service Account Credentials API:

```swift
import IAMServiceAccountCredentials

let iam = try await IAMServiceAccountCredentialsClient(
    strategy: .environment,
    client: httpClient,
    scope: [.cloudPlatform]
)

let signed = try await iam.api.signJWT(
    myPayload,
    serviceAccount: "my-sa@project.iam.gserviceaccount.com"
)
```

## Переменные окружения

### Новые переменные
- `GOOGLE_PROJECT_ID` - приоритетнее чем `PROJECT_ID`
- `NO_GCE_CHECK` - отключить проверку Compute Engine metadata server
- `GCE_METADATA_HOST` - переопределить адрес metadata server

### Существующие переменные
- `PROJECT_ID` - ID проекта
- `GOOGLE_APPLICATION_CREDENTIALS` - путь к JSON файлу или сам JSON

## Миграция кода

### Пример 1: Storage

**Было:**
```swift
import GoogleCloudKit

let config = try GoogleCloudCredentialsConfiguration(
    project: "my-project",
    credentialsFile: "/path/to/sa.json"
)

let storageConfig = GoogleCloudStorageConfiguration.default()

let gcs = try GoogleCloudStorageClient(
    credentials: config,
    storageConfig: storageConfig,
    httpClient: client,
    eventLoop: eventLoop
)

gcs.buckets.insert(name: "my-bucket").map { bucket in
    print(bucket.name)
}.whenFailure { error in
    print(error)
}
```

**Стало:**
```swift
import GoogleCloudStorage

let gcs = try await GoogleCloudStorageClient(
    strategy: .filePath("/path/to/sa.json", .serviceAccount),
    client: httpClient,
    scope: [.fullControl]
)

do {
    let bucket = try await gcs.buckets.insert(name: "my-bucket")
    print(bucket.name ?? "")
} catch {
    print(error)
}
```

### Пример 2: Datastore с агрегацией

**Новая возможность:**
```swift
let query = Query(
    filter: .property(PropertyFilter(
        op: .equal,
        property: PropertyReference("status"),
        value: Value(.string("active"))
    )),
    kind: [KindExpression("User")]
)

// Подсчет entities
let result = try await datastore.project.runAggregationQuery(
    query: query,
    aggregations: [
        .count(alias: "total"),
        .sum(alias: "totalAge", property: PropertyReference("age")),
        .avg(alias: "avgAge", property: PropertyReference("age"))
    ],
    partitionId: partitionId
)

if let total = result.batch.aggregationResults.first?.aggregateProperties["total"]?.integerValue {
    print("Total users: \(total)")
}
```

## Рекомендации

1. **Используйте async/await**: Весь код теперь использует современный async/await API
2. **Инициализируйте клиентов при старте**: Для Vapor приложений, инициализируйте клиентов в `configure.swift`
3. **Обрабатывайте ошибки**: Используйте `do-catch` вместо `.whenFailure`
4. **Переменные окружения**: Предпочтительно использовать `GOOGLE_PROJECT_ID` вместо `PROJECT_ID`

## Поддержка

Если у вас возникли проблемы при миграции, создайте issue в репозитории.

