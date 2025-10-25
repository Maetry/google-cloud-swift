//
//  FirebaseMessagingAPI.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Foundation
import AsyncHTTPClient
import NIO
import NIOFoundationCompat

public protocol FirebaseMessagingAPI: Sendable {
    /// Отправить сообщение на один токен
    func send(message: FirebaseMessage, to token: String) async throws -> FirebaseResponse
    
    /// Отправить сообщение на несколько токенов
    func sendMulticast(message: FirebaseMessage, to tokens: [String]) async throws -> FirebaseResponse
    
    /// Отправить сообщение на тему
    func sendToTopic(message: FirebaseMessage, topic: String) async throws -> FirebaseResponse
    
    /// Отправить сообщение по условию
    func sendToCondition(message: FirebaseMessage, condition: String) async throws -> FirebaseResponse
}

public struct GoogleCloudFirebaseMessagingAPI: FirebaseMessagingAPI {
    let request: GoogleCloudFirebaseMessagingRequest
    let endpoint: String
    
    public init(request: GoogleCloudFirebaseMessagingRequest, endpoint: String) {
        self.request = request
        self.endpoint = endpoint
    }
    
    /// Отправить сообщение на один токен
    public func send(message: FirebaseMessage, to token: String) async throws -> FirebaseResponse {
        var messageWithToken = message
        messageWithToken = FirebaseMessage(
            token: token,
            tokens: nil,
            topic: message.topic,
            condition: message.condition,
            data: message.data,
            notification: message.notification,
            android: message.android,
            apns: message.apns,
            webpush: message.webpush,
            fcmOptions: message.fcmOptions
        )
        
        return try await sendMessage(messageWithToken)
    }
    
    /// Отправить сообщение на несколько токенов
    public func sendMulticast(message: FirebaseMessage, to tokens: [String]) async throws -> FirebaseResponse {
        var messageWithTokens = message
        messageWithTokens = FirebaseMessage(
            token: nil,
            tokens: tokens,
            topic: message.topic,
            condition: message.condition,
            data: message.data,
            notification: message.notification,
            android: message.android,
            apns: message.apns,
            webpush: message.webpush,
            fcmOptions: message.fcmOptions
        )
        
        return try await sendMessage(messageWithTokens)
    }
    
    /// Отправить сообщение на тему
    public func sendToTopic(message: FirebaseMessage, topic: String) async throws -> FirebaseResponse {
        var messageWithTopic = message
        messageWithTopic = FirebaseMessage(
            token: message.token,
            tokens: message.tokens,
            topic: topic,
            condition: message.condition,
            data: message.data,
            notification: message.notification,
            android: message.android,
            apns: message.apns,
            webpush: message.webpush,
            fcmOptions: message.fcmOptions
        )
        
        return try await sendMessage(messageWithTopic)
    }
    
    /// Отправить сообщение по условию
    public func sendToCondition(message: FirebaseMessage, condition: String) async throws -> FirebaseResponse {
        var messageWithCondition = message
        messageWithCondition = FirebaseMessage(
            token: message.token,
            tokens: message.tokens,
            topic: message.topic,
            condition: condition,
            data: message.data,
            notification: message.notification,
            android: message.android,
            apns: message.apns,
            webpush: message.webpush,
            fcmOptions: message.fcmOptions
        )
        
        return try await sendMessage(messageWithCondition)
    }
    
    /// Внутренний метод для отправки сообщения
    private func sendMessage(_ message: FirebaseMessage) async throws -> FirebaseResponse {
        let url = "\(endpoint)/v1/projects/\(request.project)/messages:send"
        
        let requestBody = FirebaseSendRequest(message: message)
        let body = try JSONEncoder().encode(requestBody)
        
        var httpRequest = HTTPClientRequest(url: url)
        httpRequest.method = .POST
        httpRequest.headers.add(name: "Content-Type", value: "application/json")
        httpRequest.headers.add(name: "Authorization", value: "Bearer \(try await request.tokenProvider.getAccessToken())")
        httpRequest.body = .bytes(ByteBuffer(data: body))
        
        let response = try await request.client.execute(httpRequest, timeout: .seconds(30))
        let responseBody = try await response.body.collect(upTo: 1024 * 1024) // 1MB
        
        guard response.status == .ok else {
            if let error = try? JSONDecoder().decode(FirebaseError.self, from: Data(buffer: responseBody)) {
                throw FirebaseMessagingError.unknownError("FCM API Error: \(error.message)")
            } else {
                throw FirebaseMessagingError.networkError(NSError(domain: "FCM", code: Int(response.status.code), userInfo: [NSLocalizedDescriptionKey: "HTTP \(response.status.code)"]))
            }
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(FirebaseResponse.self, from: Data(buffer: responseBody))
    }
}

/// Структура запроса для отправки сообщения
private struct FirebaseSendRequest: Codable {
    let message: FirebaseMessage
}
