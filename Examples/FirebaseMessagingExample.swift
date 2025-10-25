//
//  FirebaseCloudMessageExample.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Foundation
import AsyncHTTPClient
import GoogleCloudKit

@main
struct FirebaseCloudMessageExample {
    static func main() async throws {
        // Создание HTTP клиента
        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        defer { try? httpClient.syncShutdown() }
        
        // Создание FCM клиента
        let fcmClient = try await GoogleCloudFirebaseMessagingClient(
            strategy: .environment, // Используем переменные окружения для credentials
            client: httpClient,
            scope: [.messaging]
        )
        
        // Пример 1: Простое уведомление
        print("Отправка простого уведомления...")
        let simpleMessage = FirebaseMessage.simple("Привет!", "Это тестовое уведомление из Swift", 
                                                 to: "YOUR_DEVICE_TOKEN_HERE")
        
        do {
            let response = try await fcmClient.messaging.send(
                message: simpleMessage, 
                to: "YOUR_DEVICE_TOKEN_HERE"
            )
            print("✅ Уведомление отправлено: \(response.name ?? "unknown")")
        } catch {
            print("❌ Ошибка отправки: \(error)")
        }
        
        // Пример 2: Уведомление с данными
        print("\nОтправка уведомления с данными...")
        let dataMessage = FirebaseMessage.data("Новая новость", "У нас есть важные новости для вас!", 
                                             to: "YOUR_DEVICE_TOKEN_HERE", data: [
            "type": "news",
            "id": "123",
            "url": "https://example.com/news/123",
            "category": "technology"
        ])
        
        do {
            let response = try await fcmClient.messaging.send(
                message: dataMessage, 
                to: "YOUR_DEVICE_TOKEN_HERE"
            )
            print("✅ Уведомление с данными отправлено: \(response.name ?? "unknown")")
        } catch {
            print("❌ Ошибка отправки: \(error)")
        }
        
        // Пример 3: Android-специфичное уведомление
        print("\nОтправка Android уведомления...")
        let androidMessage = FirebaseMessage(
            token: "YOUR_DEVICE_TOKEN_HERE",
            notification: FirebaseNotification(
                title: "Android уведомление",
                body: "Специально для Android устройств"
            ),
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
        
        do {
            let response = try await fcmClient.messaging.send(
                message: androidMessage, 
                to: "YOUR_DEVICE_TOKEN_HERE"
            )
            print("✅ Android уведомление отправлено: \(response.name ?? "unknown")")
        } catch {
            print("❌ Ошибка отправки: \(error)")
        }
        
        // Пример 4: iOS (APNS) уведомление
        print("\nОтправка iOS уведомления...")
        let iosMessage = FirebaseMessage(
            token: "YOUR_DEVICE_TOKEN_HERE",
            notification: FirebaseNotification(
                title: "iOS уведомление",
                body: "Специально для iOS устройств"
            ),
            apns: FirebaseAPNSConfig(
                headers: ["apns-priority": "10"],
                payload: FirebaseAPNSPayload(
                    aps: FirebaseAPS(
                        alert: FirebaseAPSAlert(
                            title: "iOS заголовок",
                            subtitle: "iOS подзаголовок",
                            body: "iOS текст"
                        ),
                        sound: "default",
                        badge: 1,
                        category: "NEWS_CATEGORY"
                    )
                )
            )
        )
        
        do {
            let response = try await fcmClient.messaging.send(
                message: iosMessage, 
                to: "YOUR_DEVICE_TOKEN_HERE"
            )
            print("✅ iOS уведомление отправлено: \(response.name ?? "unknown")")
        } catch {
            print("❌ Ошибка отправки: \(error)")
        }
        
        // Пример 5: Web push уведомление
        print("\nОтправка Web push уведомления...")
        let webMessage = FirebaseMessage(
            token: "YOUR_WEB_TOKEN_HERE",
            notification: FirebaseNotification(
                title: "Web уведомление",
                body: "Специально для веб-браузеров"
            ),
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
        
        do {
            let response = try await fcmClient.messaging.send(
                message: webMessage, 
                to: "YOUR_WEB_TOKEN_HERE"
            )
            print("✅ Web push уведомление отправлено: \(response.name ?? "unknown")")
        } catch {
            print("❌ Ошибка отправки: \(error)")
        }
        
        // Пример 6: Отправка на несколько устройств
        print("\nОтправка на несколько устройств...")
        let tokens = [
            "TOKEN_1_HERE",
            "TOKEN_2_HERE", 
            "TOKEN_3_HERE"
        ]
        
        let multicastMessage = FirebaseMessage(
            tokens: tokens,
            notification: FirebaseNotification(
                title: "Массовое уведомление",
                body: "Это уведомление отправлено на несколько устройств"
            )
        )
        
        do {
            let response = try await fcmClient.messaging.sendMulticast(
                message: multicastMessage, 
                to: tokens
            )
            print("✅ Массовое уведомление отправлено:")
            print("   Успешно: \(response.successCount ?? 0)")
            print("   Неудачно: \(response.failureCount ?? 0)")
        } catch {
            print("❌ Ошибка отправки: \(error)")
        }
        
        // Пример 7: Отправка на тему
        print("\nОтправка на тему...")
        let topicMessage = FirebaseMessage(
            topic: "news",
            notification: FirebaseNotification(
                title: "Новости",
                body: "Новая статья в теме 'news'"
            )
        )
        
        do {
            let response = try await fcmClient.messaging.sendToTopic(
                message: topicMessage, 
                topic: "news"
            )
            print("✅ Уведомление на тему отправлено: \(response.name ?? "unknown")")
        } catch {
            print("❌ Ошибка отправки: \(error)")
        }
        
        // Пример 4: Лаконичные методы
        print("\n🚀 Примеры лаконичных методов:")
        
        // Простое уведомление
        let simple = FirebaseMessage.simple("Привет!", "Как дела?", to: "device_token")
        print("✅ Простое: \(simple.notification?.title ?? "unknown")")
        
        // С данными
        let withData = FirebaseMessage.data("Новость", "Читайте подробности", to: "device_token", 
                                          data: ["url": "https://example.com"])
        print("✅ С данными: \(withData.data?["url"] ?? "unknown")")
        
        // Массовое
        let multicast = FirebaseMessage.multicast("Обновление", "Новая версия", 
                                                to: ["token1", "token2"])
        print("✅ Массовое: \(multicast.tokens?.count ?? 0) токенов")
        
        // На тему
        let topic = FirebaseMessage.topic("Новости", "Свежие новости", topic: "news")
        print("✅ На тему: \(topic.topic ?? "unknown")")
        
        // Android
        let android = FirebaseMessage.android("Android", "Только для Android", to: "android_token",
                                            channel: "news_channel", color: "#FF0000")
        print("✅ Android: \(android.android?.notification?.channelId ?? "unknown")")
        
        // iOS
        let ios = FirebaseMessage.ios("iOS", "Только для iOS", to: "ios_token",
                                    badge: 5, category: "NEWS_CATEGORY")
        print("✅ iOS: badge \(ios.apns?.payload?.aps?.badge ?? 0)")
        
        // Web
        let web = FirebaseMessage.web("Web", "Только для браузера", to: "web_token",
                                    icon: "/icon.png", url: "https://example.com")
        print("✅ Web: \(web.webpush?.notification?.icon ?? "unknown")")
        
        // С badge
        let badge = FirebaseMessage.badge("Сообщения", "У вас 5 непрочитанных", to: "device_token",
                                        count: 5, category: "messages")
        print("✅ Badge: \(badge.apns?.payload?.aps?.badge ?? 0)")
        
        // Универсальное
        let universal = FirebaseMessage.universal("Универсальное", "Работает везде", to: "device_token",
                                                badge: 3, category: "general", 
                                                data: ["type": "notification"])
        print("✅ Универсальное: \(universal.data?["type"] ?? "unknown")")
        
        print("\n🎉 Все примеры выполнены!")
        print("\n📝 Примечания:")
        print("1. Замените 'YOUR_DEVICE_TOKEN_HERE' на реальные токены устройств")
        print("2. Убедитесь, что настроены переменные окружения для авторизации Google Cloud")
        print("3. Проверьте, что у вашего проекта есть доступ к Firebase Cloud Messaging")
        print("4. Лаконичные методы делают код более читаемым и компактным! 🚀")
    }
}
