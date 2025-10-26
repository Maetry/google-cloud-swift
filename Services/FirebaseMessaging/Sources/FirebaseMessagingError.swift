//
//  FirebaseMessagingError.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Foundation

public enum FirebaseMessagingError: Error, LocalizedError {
    case invalidToken
    case invalidMessage
    case invalidTopic
    case invalidCondition
    case invalidData
    case invalidNotification
    case invalidAndroid
    case invalidAPNS
    case invalidWebpush
    case invalidFCMOptions
    case networkError(Error)
    case authenticationError(Error)
    case decodingError(Error)
    case encodingError(Error)
    case unknownError(String)
    case apiError(FirebaseError)
    case quotaExceeded
    case deviceMessageRateExceeded
    case topicsMessageRateExceeded
    case invalidRegistrationToken
    case mismatchedCredential
    case invalidPackageName
    case messageTooBig
    case invalidDataKey
    case invalidTtl
    case unavailable
    case internalError
    
    public var errorDescription: String? {
        switch self {
        case .invalidToken:
            return "Invalid FCM token"
        case .invalidMessage:
            return "Invalid message format"
        case .invalidTopic:
            return "Invalid topic name"
        case .invalidCondition:
            return "Invalid condition"
        case .invalidData:
            return "Invalid data payload"
        case .invalidNotification:
            return "Invalid notification payload"
        case .invalidAndroid:
            return "Invalid Android configuration"
        case .invalidAPNS:
            return "Invalid APNS configuration"
        case .invalidWebpush:
            return "Invalid Webpush configuration"
        case .invalidFCMOptions:
            return "Invalid FCM options"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .authenticationError(let error):
            return "Authentication error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        case .apiError(let error):
            return "FCM API Error (\(error.status)): \(error.message)"
        case .quotaExceeded:
            return "Quota exceeded for FCM"
        case .deviceMessageRateExceeded:
            return "Device message rate exceeded"
        case .topicsMessageRateExceeded:
            return "Topics message rate exceeded"
        case .invalidRegistrationToken:
            return "Invalid registration token"
        case .mismatchedCredential:
            return "Mismatched credential"
        case .invalidPackageName:
            return "Invalid package name"
        case .messageTooBig:
            return "Message too big"
        case .invalidDataKey:
            return "Invalid data key"
        case .invalidTtl:
            return "Invalid TTL"
        case .unavailable:
            return "FCM service unavailable"
        case .internalError:
            return "FCM internal error"
        }
    }
    
    /// Создает ошибку на основе FirebaseError
    public static func from(firebaseError: FirebaseError) -> FirebaseMessagingError {
        // Маппинг статусов ошибок FCM согласно официальной документации
        switch firebaseError.status {
        case "INVALID_ARGUMENT":
            if firebaseError.message.contains("registration_token") {
                return .invalidRegistrationToken
            } else if firebaseError.message.contains("package_name") {
                return .invalidPackageName
            } else if firebaseError.message.contains("data") {
                return .invalidDataKey
            } else if firebaseError.message.contains("ttl") {
                return .invalidTtl
            } else {
                return .invalidMessage
            }
        case "UNREGISTERED":
            return .invalidRegistrationToken
        case "SENDER_ID_MISMATCH":
            return .mismatchedCredential
        case "QUOTA_EXCEEDED":
            return .quotaExceeded
        case "DEVICE_MESSAGE_RATE_EXCEEDED":
            return .deviceMessageRateExceeded
        case "TOPICS_MESSAGE_RATE_EXCEEDED":
            return .topicsMessageRateExceeded
        case "INVALID_APNS_CREDENTIAL":
            return .invalidAPNS
        case "MISMATCHED_CREDENTIAL":
            return .mismatchedCredential
        case "INVALID_PACKAGE_NAME":
            return .invalidPackageName
        case "MESSAGE_TOO_BIG":
            return .messageTooBig
        case "INVALID_DATA_KEY":
            return .invalidDataKey
        case "INVALID_TTL":
            return .invalidTtl
        case "UNAVAILABLE":
            return .unavailable
        case "INTERNAL":
            return .internalError
        case "THIRD_PARTY_AUTH_ERROR":
            return .authenticationError(NSError(domain: "FCM", code: 401, userInfo: [NSLocalizedDescriptionKey: "Third party authentication error"]))
        default:
            return .apiError(firebaseError)
        }
    }
}
