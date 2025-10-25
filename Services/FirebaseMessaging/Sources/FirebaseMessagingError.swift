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
        }
    }
}
