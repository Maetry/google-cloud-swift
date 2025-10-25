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
        let simpleMessage = FirebaseMessage(
            token: "YOUR_DEVICE_TOKEN_HERE", // Замените на реальный токен
            notification: FirebaseNotification(
                title: "Привет!",
                body: "Это тестовое уведомление из Swift"
            )
        )
        
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
        let dataMessage = FirebaseMessage(
            token: "YOUR_DEVICE_TOKEN_HERE",
            data: [
                "type": "news",
                "id": "123",
                "url": "https://example.com/news/123",
                "category": "technology"
            ],
            notification: FirebaseNotification(
                title: "Новая новость",
                body: "У нас есть важные новости для вас!"
            )
        )
        
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
        
        print("\n🎉 Все примеры выполнены!")
        print("\n📝 Примечания:")
        print("1. Замените 'YOUR_DEVICE_TOKEN_HERE' на реальные токены устройств")
        print("2. Убедитесь, что настроены переменные окружения для авторизации Google Cloud")
        print("3. Проверьте, что у вашего проекта есть доступ к Firebase Cloud Messaging")
    }
}
