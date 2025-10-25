//
//  VaporFirebaseCloudMessageExample.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Vapor
import GoogleCloudKit

/// Пример Vapor приложения с Firebase Cloud Messaging
struct VaporFirebaseCloudMessageExample {
    
    /// Настройка приложения
    static func configure(_ app: Application) async throws {
        // Настройка Firebase Messaging (как в Storage)
        app.googleCloud.firebaseMessagingConfiguration = GoogleCloudFirebaseMessagingConfiguration(
            scope: [.messaging],
            base: "https://fcm.googleapis.com"
        )
        
        // Опционально: предварительная инициализация
        app.lifecycle.use(GoogleCloudFirebaseMessagingLifecycle())
        
        // Регистрация маршрутов
        try routes(app)
    }
    
    /// Настройка маршрутов
    static func routes(_ app: Application) throws {
        let api = app.grouped("api", "fcm")
        
        // Отправка простого уведомления
        api.post("send", use: sendNotification)
        
        // Отправка уведомления с данными
        api.post("send-data", use: sendNotificationWithData)
        
        // Отправка на несколько устройств
        api.post("send-multicast", use: sendMulticastNotification)
        
        // Отправка на тему
        api.post("send-topic", use: sendTopicNotification)
        
        // Отправка Android уведомления
        api.post("send-android", use: sendAndroidNotification)
        
        // Отправка iOS уведомления
        api.post("send-ios", use: sendIOSNotification)
        
        // Отправка Web push уведомления
        api.post("send-web", use: sendWebNotification)
    }
    
    /// Отправка простого уведомления
    static func sendNotification(req: Request) async throws -> Response {
        let body = try req.content.decode(SendNotificationRequest.self)
        
        let message = FirebaseMessage(
            token: body.token,
            notification: FirebaseNotification(
                title: body.title,
                body: body.body
            )
        )
        
        let firebase = try await req.googleCloudFirebaseMessaging()
        let response = try await firebase.messaging.send(
            message: message, 
            to: body.token
        )
        
        return Response(
            status: .ok,
            body: .init(data: try JSONEncoder().encode([
                "success": true,
                "messageId": response.name ?? "unknown"
            ]))
        )
    }
    
    /// Отправка уведомления с данными
    static func sendNotificationWithData(req: Request) async throws -> Response {
        let body = try req.content.decode(SendDataNotificationRequest.self)
        
        let message = FirebaseMessage(
            token: body.token,
            data: body.data,
            notification: FirebaseNotification(
                title: body.title,
                body: body.body
            )
        )
        
        let messaging = try await req.googleCloudFirebaseMessaging()
        let response = try await messaging.messaging.send(
            message: message, 
            to: body.token
        )
        
        return Response(
            status: .ok,
            body: .init(data: try JSONEncoder().encode([
                "success": true,
                "messageId": response.name ?? "unknown"
            ]))
        )
    }
    
    /// Отправка на несколько устройств
    static func sendMulticastNotification(req: Request) async throws -> Response {
        let body = try req.content.decode(SendMulticastRequest.self)
        
        let message = FirebaseMessage(
            tokens: body.tokens,
            notification: FirebaseNotification(
                title: body.title,
                body: body.body
            )
        )
        
        let messaging = try await req.googleCloudFirebaseMessaging()
        let response = try await messaging.messaging.sendMulticast(
            message: message, 
            to: body.tokens
        )
        
        return Response(
            status: .ok,
            body: .init(data: try JSONEncoder().encode([
                "success": true,
                "successCount": response.successCount ?? 0,
                "failureCount": response.failureCount ?? 0,
                "results": response.results ?? []
            ]))
        )
    }
    
    /// Отправка на тему
    static func sendTopicNotification(req: Request) async throws -> Response {
        let body = try req.content.decode(SendTopicRequest.self)
        
        let message = FirebaseMessage(
            topic: body.topic,
            notification: FirebaseNotification(
                title: body.title,
                body: body.body
            )
        )
        
        let messaging = try await req.googleCloudFirebaseMessaging()
        let response = try await messaging.messaging.sendToTopic(
            message: message, 
            topic: body.topic
        )
        
        return Response(
            status: .ok,
            body: .init(data: try JSONEncoder().encode([
                "success": true,
                "messageId": response.name ?? "unknown"
            ]))
        )
    }
    
    /// Отправка Android уведомления
    static func sendAndroidNotification(req: Request) async throws -> Response {
        let body = try req.content.decode(SendAndroidRequest.self)
        
        let message = FirebaseMessage(
            token: body.token,
            notification: FirebaseNotification(
                title: body.title,
                body: body.body
            ),
            android: FirebaseAndroidConfig(
                priority: body.priority ?? "high",
                ttl: body.ttl ?? "3600s",
                notification: FirebaseAndroidNotification(
                    title: body.title,
                    body: body.body,
                    icon: body.icon ?? "ic_notification",
                    color: body.color ?? "#FF0000",
                    sound: body.sound ?? "default",
                    channelId: body.channelId ?? "default_channel"
                )
            )
        )
        
        let messaging = try await req.googleCloudFirebaseMessaging()
        let response = try await messaging.messaging.send(
            message: message, 
            to: body.token
        )
        
        return Response(
            status: .ok,
            body: .init(data: try JSONEncoder().encode([
                "success": true,
                "messageId": response.name ?? "unknown"
            ]))
        )
    }
    
    /// Отправка iOS уведомления
    static func sendIOSNotification(req: Request) async throws -> Response {
        let body = try req.content.decode(SendIOSRequest.self)
        
        let message = FirebaseMessage(
            token: body.token,
            notification: FirebaseNotification(
                title: body.title,
                body: body.body
            ),
            apns: FirebaseAPNSConfig(
                headers: ["apns-priority": "10"],
                payload: FirebaseAPNSPayload(
                    aps: FirebaseAPS(
                        alert: FirebaseAPSAlert(
                            title: body.title,
                            subtitle: body.subtitle,
                            body: body.body
                        ),
                        sound: body.sound ?? "default",
                        badge: body.badge,
                        category: body.category
                    )
                )
            )
        )
        
        let messaging = try await req.googleCloudFirebaseMessaging()
        let response = try await messaging.messaging.send(
            message: message, 
            to: body.token
        )
        
        return Response(
            status: .ok,
            body: .init(data: try JSONEncoder().encode([
                "success": true,
                "messageId": response.name ?? "unknown"
            ]))
        )
    }
    
    /// Отправка Web push уведомления
    static func sendWebNotification(req: Request) async throws -> Response {
        let body = try req.content.decode(SendWebRequest.self)
        
        let message = FirebaseMessage(
            token: body.token,
            notification: FirebaseNotification(
                title: body.title,
                body: body.body
            ),
            webpush: FirebaseWebpushConfig(
                headers: ["TTL": "300"],
                notification: FirebaseWebpushNotification(
                    title: body.title,
                    body: body.body,
                    icon: body.icon ?? "/icon.png",
                    url: body.url,
                    actions: body.actions?.map { action in
                        FirebaseWebpushAction(
                            action: action.action,
                            title: action.title,
                            icon: action.icon
                        )
                    }
                )
            )
        )
        
        let messaging = try await req.googleCloudFirebaseMessaging()
        let response = try await messaging.messaging.send(
            message: message, 
            to: body.token
        )
        
        return Response(
            status: .ok,
            body: .init(data: try JSONEncoder().encode([
                "success": true,
                "messageId": response.name ?? "unknown"
            ]))
        )
    }
}

// MARK: - Request Models

struct SendNotificationRequest: Content {
    let token: String
    let title: String
    let body: String
}

struct SendDataNotificationRequest: Content {
    let token: String
    let title: String
    let body: String
    let data: [String: String]
}

struct SendMulticastRequest: Content {
    let tokens: [String]
    let title: String
    let body: String
}

struct SendTopicRequest: Content {
    let topic: String
    let title: String
    let body: String
}

struct SendAndroidRequest: Content {
    let token: String
    let title: String
    let body: String
    let priority: String?
    let ttl: String?
    let icon: String?
    let color: String?
    let sound: String?
    let channelId: String?
}

struct SendIOSRequest: Content {
    let token: String
    let title: String
    let subtitle: String?
    let body: String
    let sound: String?
    let badge: Int?
    let category: String?
}

struct SendWebRequest: Content {
    let token: String
    let title: String
    let body: String
    let icon: String?
    let url: String?
    let actions: [WebAction]?
}

struct WebAction: Content {
    let action: String
    let title: String
    let icon: String?
}

// MARK: - Main

@main
struct App {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = Application(env)
        defer { app.shutdown() }
        
        try await VaporFirebaseCloudMessageExample.configure(app)
        try await app.run()
    }
}
