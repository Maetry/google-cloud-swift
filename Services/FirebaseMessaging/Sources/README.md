# Firebase Messaging

Firebase Messaging (FCM) сервис для отправки push-уведомлений на мобильные устройства и веб-приложения.

## Возможности

- Отправка уведомлений на один токен устройства
- Отправка уведомлений на несколько токенов (multicast)
- Отправка уведомлений на темы (topics)
- Отправка уведомлений по условиям (conditions)
- Поддержка Android, iOS (APNS) и Web push уведомлений
- Интеграция с Vapor

## Использование

### Инициализация клиента

```swift
import GoogleCloudKit

// Создание клиента
let client = try await GoogleCloudFirebaseMessagingClient(
    strategy: .environment, // или другой способ загрузки credentials
    client: httpClient,
    scope: [.messaging]
)
```

### Отправка простого уведомления

```swift
// Простой способ
let message = FirebaseMessage.simple(
    token: "device_token_here",
    title: "Заголовок",
    body: "Текст уведомления"
)

// Отправка
let response = try await client.messaging.send(message: message, to: "device_token")
print("Message sent: \(response.name ?? "unknown")")
```

### Отправка на несколько устройств

```swift
let tokens = ["token1", "token2", "token3"]
let response = try await client.messaging.sendMulticast(message: message, to: tokens)
print("Success: \(response.successCount ?? 0), Failed: \(response.failureCount ?? 0)")
```

### Отправка на тему

```swift
let response = try await client.messaging.sendToTopic(message: message, topic: "news")
```

### Отправка с данными

```swift
let message = FirebaseMessage(
    token: "device_token",
    data: [
        "type": "news",
        "id": "123",
        "url": "https://example.com/news/123"
    ],
    notification: FirebaseNotification(
        title: "Новая новость",
        body: "У нас есть важные новости для вас"
    )
)
```

### Android-специфичные настройки

```swift
let message = FirebaseMessage(
    token: "device_token",
    notification: FirebaseNotification(title: "Заголовок", body: "Текст"),
    android: FirebaseAndroidConfig(
        priority: "high",
        ttl: "3600s",
        notification: FirebaseAndroidNotification(
            title: "Android заголовок",
            body: "Android текст",
            icon: "ic_notification",
            color: "#FF0000",
            sound: "default",
            channelId: "news_channel"
        )
    )
)
```

### iOS (APNS) настройки

```swift
let message = FirebaseMessage(
    token: "device_token",
    notification: FirebaseNotification(title: "Заголовок", body: "Текст"),
    apns: FirebaseAPNSConfig(
        headers: ["apns-priority": "10"],
        payload: FirebaseAPNSPayload(
            aps: FirebaseAPS(
                alert: FirebaseAPSAlert(
                    title: "iOS заголовок",
                    subtitle: "Подзаголовок",
                    body: "iOS текст"
                ),
                sound: "default",
                badge: 1,
                category: "NEWS_CATEGORY"
            )
        )
    )
)
```

### Web push настройки

```swift
let message = FirebaseMessage(
    token: "web_token",
    notification: FirebaseNotification(title: "Заголовок", body: "Текст"),
    webpush: FirebaseWebpushConfig(
        headers: ["TTL": "300"],
        notification: FirebaseWebpushNotification(
            title: "Web заголовок",
            body: "Web текст",
            icon: "/icon.png",
            url: "https://example.com",
            actions: [
                FirebaseWebpushAction(action: "view", title: "Посмотреть"),
                FirebaseWebpushAction(action: "dismiss", title: "Закрыть")
            ]
        )
    )
)
```

## Интеграция с Vapor

### Настройка в configure.swift

```swift
import GoogleCloudKit

public func configure(_ app: Application) async throws {
        // Настройка Firebase Messaging
        try await configureFirebaseMessaging(
        app,
        strategy: .environment,
        scope: [.messaging]
    )
}
```

### Использование в контроллерах

```swift
import Vapor
import GoogleCloudKit

struct NotificationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("send", use: sendNotification)
    }
    
    func sendNotification(req: Request) async throws -> Response {
        let message = FirebaseMessage(
            token: "device_token",
            notification: FirebaseNotification(
                title: "Уведомление",
                body: "Это тестовое уведомление"
            )
        )
        
        let response = try await req.firebaseMessaging.messaging.send(
            message: message, 
            to: "device_token"
        )
        
        return Response(status: .ok, body: .init(string: "Notification sent: \(response.name ?? "unknown")"))
    }
}
```

## Авторизация

Сервис использует существующую систему авторизации Google Cloud:

- **Service Account** - для серверных приложений (рекомендуется)
- **GCloud credentials** - для локальной разработки
- **Compute Engine** - для приложений на Google Cloud

## Обработка ошибок

```swift
do {
    let response = try await client.messaging.send(message: message, to: token)
    print("Success: \(response.name ?? "unknown")")
} catch FirebaseMessagingError.invalidToken {
    print("Неверный токен устройства")
} catch FirebaseMessagingError.networkError(let error) {
    print("Ошибка сети: \(error)")
} catch {
    print("Неизвестная ошибка: \(error)")
}
```

## Лаконичные методы создания сообщений

### 🚀 Базовые уведомления

```swift
// Простое уведомление
let message = FirebaseMessage.simple("Привет!", "Как дела?", to: "device_token")

// С данными
let message = FirebaseMessage.data("Новость", "Читайте подробности", to: "device_token", 
                                  data: ["url": "https://example.com"])

// Массовое уведомление
let message = FirebaseMessage.multicast("Обновление", "Новая версия доступна", 
                                       to: ["token1", "token2", "token3"])

// На тему
let message = FirebaseMessage.topic("Новости", "Свежие новости", topic: "news")

// По условию
let message = FirebaseMessage.conditional("Скидка", "Специальное предложение", 
                                         condition: "'premium' in topics")
```

### 📱 Платформо-специфичные

```swift
// Android
let message = FirebaseMessage.android("Android", "Только для Android", to: "android_token",
                                     channel: "news_channel", color: "#FF0000")

// iOS
let message = FirebaseMessage.ios("iOS", "Только для iOS", to: "ios_token",
                                 badge: 5, category: "NEWS_CATEGORY")

// Web
let message = FirebaseMessage.web("Web", "Только для браузера", to: "web_token",
                                 icon: "/icon.png", url: "https://example.com")
```

### 🔢 Счетчик непрочитанных

```swift
let message = FirebaseMessage.badge("Сообщения", "У вас 5 непрочитанных", to: "device_token",
                                   count: 5, category: "messages")
```

### 🌐 Универсальное уведомление

```swift
let message = FirebaseMessage.universal("Универсальное", "Работает везде", to: "device_token",
                                       badge: 3, category: "general", 
                                       data: ["type": "notification"])
```

### 📊 Преимущества лаконичного стиля

```swift
// ✅ Лаконичный стиль (читаемо и компактно)
let message = FirebaseMessage.simple("Заголовок", "Текст уведомления", to: "device_token")

// ✅ С данными
let dataMessage = FirebaseMessage.data("Новость", "Читайте подробности", to: "device_token", 
                                     data: ["url": "https://example.com"])

// ✅ Платформо-специфичные
let androidMessage = FirebaseMessage.android("Android", "Только для Android", to: "android_token",
                                           channel: "news_channel", color: "#FF0000")
```

## Требования

- Swift 5.7+
- Vapor 4.0+ (для интеграции с Vapor)
- AsyncHTTPClient
- JWTKit (для авторизации)
