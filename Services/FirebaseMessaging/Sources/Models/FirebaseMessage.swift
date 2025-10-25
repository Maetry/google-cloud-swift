//
//  FirebaseMessage.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Foundation

/// Основная структура сообщения FCM
public struct FirebaseMessage: Codable, Sendable {
    /// Токен устройства или массив токенов
    public let token: String?
    public let tokens: [String]?
    
    /// Тема для отправки
    public let topic: String?
    
    /// Условие для отправки
    public let condition: String?
    
    /// Данные сообщения
    public let data: [String: String]?
    
    /// Уведомление
    public let notification: FirebaseNotification?
    
    /// Android-специфичные настройки
    public let android: FirebaseAndroidConfig?
    
    /// APNS-специфичные настройки
    public let apns: FirebaseAPNSConfig?
    
    /// Webpush-специфичные настройки
    public let webpush: FirebaseWebpushConfig?
    
    /// FCM-специфичные опции
    public let fcmOptions: FirebaseFCMOptions?
    
    public init(token: String? = nil,
                tokens: [String]? = nil,
                topic: String? = nil,
                condition: String? = nil,
                data: [String: String]? = nil,
                notification: FirebaseNotification? = nil,
                android: FirebaseAndroidConfig? = nil,
                apns: FirebaseAPNSConfig? = nil,
                webpush: FirebaseWebpushConfig? = nil,
                fcmOptions: FirebaseFCMOptions? = nil) {
        self.token = token
        self.tokens = tokens
        self.topic = topic
        self.condition = condition
        self.data = data
        self.notification = notification
        self.android = android
        self.apns = apns
        self.webpush = webpush
        self.fcmOptions = fcmOptions
    }
}

/// Уведомление для отображения пользователю
public struct FirebaseNotification: Codable, Sendable {
    /// Заголовок уведомления
    public let title: String?
    
    /// Текст уведомления
    public let body: String?
    
    /// URL изображения
    public let image: String?
    
    public init(title: String? = nil, body: String? = nil, image: String? = nil) {
        self.title = title
        self.body = body
        self.image = image
    }
}

/// Android-специфичные настройки
public struct FirebaseAndroidConfig: Codable, Sendable {
    /// Приоритет сообщения
    public let priority: String?
    
    /// TTL (Time To Live) в секундах
    public let ttl: String?
    
    /// Канал уведомлений
    public let notification: FirebaseAndroidNotification?
    
    /// Данные
    public let data: [String: String]?
    
    public init(priority: String? = nil,
                ttl: String? = nil,
                notification: FirebaseAndroidNotification? = nil,
                data: [String: String]? = nil) {
        self.priority = priority
        self.ttl = ttl
        self.notification = notification
        self.data = data
    }
}

/// Android-специфичные настройки уведомления
public struct FirebaseAndroidNotification: Codable, Sendable {
    /// Заголовок
    public let title: String?
    
    /// Текст
    public let body: String?
    
    /// Иконка
    public let icon: String?
    
    /// Цвет иконки
    public let color: String?
    
    /// Звук
    public let sound: String?
    
    /// Тег
    public let tag: String?
    
    /// URL изображения
    public let image: String?
    
    /// Клик-действие
    public let clickAction: String?
    
    /// Канал уведомлений
    public let channelId: String?
    
    public init(title: String? = nil,
                body: String? = nil,
                icon: String? = nil,
                color: String? = nil,
                sound: String? = nil,
                tag: String? = nil,
                image: String? = nil,
                clickAction: String? = nil,
                channelId: String? = nil) {
        self.title = title
        self.body = body
        self.icon = icon
        self.color = color
        self.sound = sound
        self.tag = tag
        self.image = image
        self.clickAction = clickAction
        self.channelId = channelId
    }
}

/// APNS-специфичные настройки
public struct FirebaseAPNSConfig: Codable, Sendable {
    /// Заголовки
    public let headers: [String: String]?
    
    /// Полезная нагрузка
    public let payload: FirebaseAPNSPayload?
    
    public init(headers: [String: String]? = nil, payload: FirebaseAPNSPayload? = nil) {
        self.headers = headers
        self.payload = payload
    }
}

/// APNS полезная нагрузка
public struct FirebaseAPNSPayload: Codable, Sendable {
    /// Aps данные
    public let aps: FirebaseAPS?
    
    /// Дополнительные данные
    public let data: [String: String]?
    
    public init(aps: FirebaseAPS? = nil, data: [String: String]? = nil) {
        self.aps = aps
        self.data = data
    }
}

/// APS структура для APNS
public struct FirebaseAPS: Codable, Sendable {
    /// Оповещение
    public let alert: FirebaseAPSAlert?
    
    /// Звук
    public let sound: String?
    
    /// Badge
    public let badge: Int?
    
    /// Content-available
    public let contentAvailable: Int?
    
    /// Mutable-content
    public let mutableContent: Int?
    
    /// Category
    public let category: String?
    
    /// Thread-id
    public let threadId: String?
    
    enum CodingKeys: String, CodingKey {
        case alert, sound, badge, category
        case contentAvailable = "content-available"
        case mutableContent = "mutable-content"
        case threadId = "thread-id"
    }
    
    public init(alert: FirebaseAPSAlert? = nil,
                sound: String? = nil,
                badge: Int? = nil,
                contentAvailable: Int? = nil,
                mutableContent: Int? = nil,
                category: String? = nil,
                threadId: String? = nil) {
        self.alert = alert
        self.sound = sound
        self.badge = badge
        self.contentAvailable = contentAvailable
        self.mutableContent = mutableContent
        self.category = category
        self.threadId = threadId
    }
}

/// APS Alert структура
public struct FirebaseAPSAlert: Codable, Sendable {
    /// Заголовок
    public let title: String?
    
    /// Подзаголовок
    public let subtitle: String?
    
    /// Текст
    public let body: String?
    
    public init(title: String? = nil, subtitle: String? = nil, body: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }
}

/// Webpush-специфичные настройки
public struct FirebaseWebpushConfig: Codable, Sendable {
    /// Заголовки
    public let headers: [String: String]?
    
    /// Данные
    public let data: [String: String]?
    
    /// Уведомление
    public let notification: FirebaseWebpushNotification?
    
    public init(headers: [String: String]? = nil,
                data: [String: String]? = nil,
                notification: FirebaseWebpushNotification? = nil) {
        self.headers = headers
        self.data = data
        self.notification = notification
    }
}

/// Webpush уведомление
public struct FirebaseWebpushNotification: Codable, Sendable {
    /// Заголовок
    public let title: String?
    
    /// Текст
    public let body: String?
    
    /// Иконка
    public let icon: String?
    
    /// URL изображения
    public let image: String?
    
    /// URL действия
    public let url: String?
    
    /// Теги
    public let tag: String?
    
    /// Данные
    public let data: [String: String]?
    
    /// Действия
    public let actions: [FirebaseWebpushAction]?
    
    /// Badge
    public let badge: String?
    
    /// Вибрация
    public let vibrate: [Int]?
    
    /// Таймстамп
    public let timestamp: Int?
    
    /// Требует взаимодействия
    public let requireInteraction: Bool?
    
    /// Силент
    public let silent: Bool?
    
    public init(title: String? = nil,
                body: String? = nil,
                icon: String? = nil,
                image: String? = nil,
                url: String? = nil,
                tag: String? = nil,
                data: [String: String]? = nil,
                actions: [FirebaseWebpushAction]? = nil,
                badge: String? = nil,
                vibrate: [Int]? = nil,
                timestamp: Int? = nil,
                requireInteraction: Bool? = nil,
                silent: Bool? = nil) {
        self.title = title
        self.body = body
        self.icon = icon
        self.image = image
        self.url = url
        self.tag = tag
        self.data = data
        self.actions = actions
        self.badge = badge
        self.vibrate = vibrate
        self.timestamp = timestamp
        self.requireInteraction = requireInteraction
        self.silent = silent
    }
}

/// Webpush действие
public struct FirebaseWebpushAction: Codable, Sendable {
    /// Действие
    public let action: String
    
    /// Заголовок
    public let title: String
    
    /// Иконка
    public let icon: String?
    
    public init(action: String, title: String, icon: String? = nil) {
        self.action = action
        self.title = title
        self.icon = icon
    }
}

/// FCM-специфичные опции
public struct FirebaseFCMOptions: Codable, Sendable {
    /// Аналитика
    public let analyticsLabel: String?
    
    public init(analyticsLabel: String? = nil) {
        self.analyticsLabel = analyticsLabel
    }
}

// MARK: - Convenience Extensions

extension FirebaseMessage {
    
    // MARK: - Basic Messages
    
    /// Простое уведомление
    public static func simple(_ title: String, _ body: String, to token: String) -> FirebaseMessage {
        FirebaseMessage(
            token: token,
            notification: FirebaseNotification(title: title, body: body)
        )
    }
    
    /// Уведомление с данными
    public static func data(_ title: String, _ body: String, to token: String, data: [String: String]) -> FirebaseMessage {
        FirebaseMessage(
            token: token,
            data: data,
            notification: FirebaseNotification(title: title, body: body)
        )
    }
    
    /// Массовое уведомление
    public static func multicast(_ title: String, _ body: String, to tokens: [String]) -> FirebaseMessage {
        FirebaseMessage(
            tokens: tokens,
            notification: FirebaseNotification(title: title, body: body)
        )
    }
    
    /// Уведомление на тему
    public static func topic(_ title: String, _ body: String, topic: String) -> FirebaseMessage {
        FirebaseMessage(
            topic: topic,
            notification: FirebaseNotification(title: title, body: body)
        )
    }
    
    /// Уведомление по условию
    public static func conditional(_ title: String, _ body: String, condition: String) -> FirebaseMessage {
        FirebaseMessage(
            condition: condition,
            notification: FirebaseNotification(title: title, body: body)
        )
    }
    
    // MARK: - Platform Specific
    
    /// Android уведомление
    public static func android(_ title: String, _ body: String, to token: String, 
                              channel: String? = nil, color: String? = nil) -> FirebaseMessage {
        FirebaseMessage(
            token: token,
            notification: FirebaseNotification(title: title, body: body),
            android: FirebaseAndroidConfig(
                priority: "high",
                notification: FirebaseAndroidNotification(
                    title: title,
                    body: body,
                    color: color,
                    channelId: channel
                )
            )
        )
    }
    
    /// iOS уведомление
    public static func ios(_ title: String, _ body: String, to token: String,
                          badge: Int? = nil, category: String? = nil) -> FirebaseMessage {
        FirebaseMessage(
            token: token,
            notification: FirebaseNotification(title: title, body: body),
            apns: FirebaseAPNSConfig(
                headers: ["apns-priority": "10"],
                payload: FirebaseAPNSPayload(
                    aps: FirebaseAPS(
                        alert: FirebaseAPSAlert(title: title, body: body),
                        badge: badge,
                        category: category
                    )
                )
            )
        )
    }
    
    /// Web push уведомление
    public static func web(_ title: String, _ body: String, to token: String,
                          icon: String? = nil, url: String? = nil) -> FirebaseMessage {
        FirebaseMessage(
            token: token,
            notification: FirebaseNotification(title: title, body: body),
            webpush: FirebaseWebpushConfig(
                headers: ["TTL": "300"],
                notification: FirebaseWebpushNotification(
                    title: title,
                    body: body,
                    icon: icon,
                    url: url
                )
            )
        )
    }
    
    // MARK: - Advanced Messages
    
    /// Уведомление с badge (счетчик непрочитанных)
    public static func badge(_ title: String, _ body: String, to token: String,
                            count: Int, category: String? = nil) -> FirebaseMessage {
        FirebaseMessage(
            token: token,
            notification: FirebaseNotification(title: title, body: body),
            apns: FirebaseAPNSConfig(
                payload: FirebaseAPNSPayload(
                    aps: FirebaseAPS(
                        badge: count,
                        category: category
                    )
                )
            ),
            webpush: FirebaseWebpushConfig(
                notification: FirebaseWebpushNotification(
                    title: title,
                    body: body,
                    badge: String(count)
                )
            )
        )
    }
    
    /// Кроссплатформенное уведомление
    public static func universal(_ title: String, _ body: String, to token: String,
                                badge: Int? = nil, category: String? = nil,
                                data: [String: String]? = nil) -> FirebaseMessage {
        FirebaseMessage(
            token: token,
            data: data,
            notification: FirebaseNotification(title: title, body: body),
            apns: badge != nil || category != nil ? FirebaseAPNSConfig(
                payload: FirebaseAPNSPayload(
                    aps: FirebaseAPS(
                        badge: badge,
                        category: category
                    )
                )
            ) : nil,
            webpush: badge != nil ? FirebaseWebpushConfig(
                notification: FirebaseWebpushNotification(
                    title: title,
                    body: body,
                    badge: String(badge!)
                )
            ) : nil
        )
    }
    
}
