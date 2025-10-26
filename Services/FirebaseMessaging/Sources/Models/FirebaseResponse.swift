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
    
    /// Получить успешные результаты отправки
    public var successfulResults: [FirebaseSendResult] {
        return results?.filter { $0.isSuccess } ?? []
    }
    
    /// Получить неудачные результаты отправки
    public var failedResults: [FirebaseSendResult] {
        return results?.filter { !$0.isSuccess } ?? []
    }
    
    /// Получить результаты с каноническими токенами (нужно обновить)
    public var canonicalResults: [FirebaseSendResult] {
        return results?.filter { $0.hasCanonicalToken } ?? []
    }
    
    /// Проверить, была ли отправка полностью успешной
    public var isFullySuccessful: Bool {
        return (failureCount ?? 0) == 0
    }
    
    /// Получить общее количество обработанных токенов
    public var totalProcessed: Int {
        return (successCount ?? 0) + (failureCount ?? 0)
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
    
    /// Проверяет, была ли отправка успешной
    public var isSuccess: Bool {
        return messageId != nil && errorCode == nil
    }
    
    /// Проверяет, есть ли канонический токен (нужно обновить)
    public var hasCanonicalToken: Bool {
        return canonicalRegistrationToken != nil
    }
}

/// Ошибка FCM согласно официальной документации Firebase
public struct FirebaseError: Codable, Sendable {
    /// Код ошибки HTTP
    public let code: Int
    
    /// Сообщение об ошибке
    public let message: String
    
    /// Статус ошибки
    public let status: String
    
    /// Детали ошибки
    public let details: [FirebaseErrorDetail]?
    
    public init(code: Int, message: String, status: String, details: [FirebaseErrorDetail]? = nil) {
        self.code = code
        self.message = message
        self.status = status
        self.details = details
    }
}

/// Структура для декодирования полного ответа с ошибкой от FCM API
public struct FirebaseErrorResponse: Codable, Sendable {
    /// Объект ошибки
    public let error: FirebaseError
    
    public init(error: FirebaseError) {
        self.error = error
    }
}

/// Коды ошибок FCM согласно официальной документации Firebase
public enum FCMErrorCode: String, Codable, CaseIterable {
    case unspecifiedError = "UNSPECIFIED_ERROR"
    case invalidArgument = "INVALID_ARGUMENT"
    case unregistered = "UNREGISTERED"
    case senderIdMismatch = "SENDER_ID_MISMATCH"
    case quotaExceeded = "QUOTA_EXCEEDED"
    case deviceMessageRateExceeded = "DEVICE_MESSAGE_RATE_EXCEEDED"
    case topicsMessageRateExceeded = "TOPICS_MESSAGE_RATE_EXCEEDED"
    case invalidApnsCredential = "INVALID_APNS_CREDENTIAL"
    case mismatchedCredential = "MISMATCHED_CREDENTIAL"
    case invalidPackageName = "INVALID_PACKAGE_NAME"
    case messageTooBig = "MESSAGE_TOO_BIG"
    case invalidDataKey = "INVALID_DATA_KEY"
    case invalidTtl = "INVALID_TTL"
    case unavailable = "UNAVAILABLE"
    case internalError = "INTERNAL"
    case thirdPartyAuthError = "THIRD_PARTY_AUTH_ERROR"
    
    /// Описание ошибки на русском языке
    public var localizedDescription: String {
        switch self {
        case .unspecifiedError:
            return "Неопределенная ошибка"
        case .invalidArgument:
            return "Недопустимый аргумент"
        case .unregistered:
            return "Токен не зарегистрирован"
        case .senderIdMismatch:
            return "Несоответствие Sender ID"
        case .quotaExceeded:
            return "Превышена квота"
        case .deviceMessageRateExceeded:
            return "Превышена частота сообщений для устройства"
        case .topicsMessageRateExceeded:
            return "Превышена частота сообщений для топика"
        case .invalidApnsCredential:
            return "Недопустимые учетные данные APNS"
        case .mismatchedCredential:
            return "Несоответствие учетных данных"
        case .invalidPackageName:
            return "Недопустимое имя пакета"
        case .messageTooBig:
            return "Сообщение слишком большое"
        case .invalidDataKey:
            return "Недопустимый ключ данных"
        case .invalidTtl:
            return "Недопустимое время жизни (TTL)"
        case .unavailable:
            return "Сервис недоступен"
        case .internalError:
            return "Внутренняя ошибка"
        case .thirdPartyAuthError:
            return "Ошибка аутентификации третьей стороны"
        }
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
