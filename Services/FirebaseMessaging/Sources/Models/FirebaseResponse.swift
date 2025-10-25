//
//  FirebaseResponse.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Foundation

/// Ответ от FCM API
public struct FirebaseResponse: Codable, Sendable {
    /// Имя сообщения
    public let name: String?
    
    /// Результаты отправки (для множественных токенов)
    public let results: [FirebaseSendResult]?
    
    /// Количество успешных отправок
    public let successCount: Int?
    
    /// Количество неудачных отправок
    public let failureCount: Int?
    
    /// Количество канонических токенов
    public let canonicalIds: Int?
    
    /// Количество мультикаст ID
    public let multicastId: Int?
    
    public init(name: String? = nil,
                results: [FirebaseSendResult]? = nil,
                successCount: Int? = nil,
                failureCount: Int? = nil,
                canonicalIds: Int? = nil,
                multicastId: Int? = nil) {
        self.name = name
        self.results = results
        self.successCount = successCount
        self.failureCount = failureCount
        self.canonicalIds = canonicalIds
        self.multicastId = multicastId
    }
}

/// Результат отправки для одного токена
public struct FirebaseSendResult: Codable, Sendable {
    /// Сообщение ID
    public let messageId: String?
    
    /// Канонический токен
    public let canonicalRegistrationToken: String?
    
    /// Код ошибки
    public let errorCode: String?
    
    /// Описание ошибки
    public let errorDescription: String?
    
    public init(messageId: String? = nil,
                canonicalRegistrationToken: String? = nil,
                errorCode: String? = nil,
                errorDescription: String? = nil) {
        self.messageId = messageId
        self.canonicalRegistrationToken = canonicalRegistrationToken
        self.errorCode = errorCode
        self.errorDescription = errorDescription
    }
}

/// Ошибка FCM
public struct FirebaseError: Codable, Sendable {
    /// Код ошибки
    public let code: Int
    
    /// Сообщение об ошибке
    public let message: String
    
    /// Статус
    public let status: String
    
    /// Детали
    public let details: [FirebaseErrorDetail]?
    
    public init(code: Int, message: String, status: String, details: [FirebaseErrorDetail]? = nil) {
        self.code = code
        self.message = message
        self.status = status
        self.details = details
    }
}

/// Детали ошибки FCM
public struct FirebaseErrorDetail: Codable, Sendable {
    /// Тип ошибки
    public let type: String?
    
    /// Детали
    public let detail: String?
    
    public init(type: String? = nil, detail: String? = nil) {
        self.type = type
        self.detail = detail
    }
}
