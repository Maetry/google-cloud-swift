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
    /// Отправить сообщение (универсальный метод)
    func send(_ message: FirebaseMessage) async throws -> FirebaseResponse
}

public struct GoogleCloudFirebaseMessagingAPI: FirebaseMessagingAPI {
    let request: GoogleCloudFirebaseMessagingRequest
    let endpoint: String
    
    public init(request: GoogleCloudFirebaseMessagingRequest, endpoint: String) {
        self.request = request
        self.endpoint = endpoint
    }
    
    /// Отправить сообщение (универсальный метод)
    public func send(_ message: FirebaseMessage) async throws -> FirebaseResponse {
        return try await sendMessage(message)
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
            // Создаем декодер с правильной стратегией для snake_case
            let errorDecoder = JSONDecoder()
            errorDecoder.keyDecodingStrategy = .convertFromSnakeCase
            
            // Сначала пытаемся декодировать полный ответ с ошибкой
            if let errorResponse = try? errorDecoder.decode(FirebaseErrorResponse.self, from: Data(buffer: responseBody)) {
                throw FirebaseMessagingError.from(firebaseError: errorResponse.error)
            }
            // Если не получилось, пытаемся декодировать только ошибку
            else if let error = try? errorDecoder.decode(FirebaseError.self, from: Data(buffer: responseBody)) {
                throw FirebaseMessagingError.from(firebaseError: error)
            } else {
                // Если не удалось декодировать ошибку, выводим сырой ответ для отладки
                let rawResponse = String(data: Data(buffer: responseBody), encoding: .utf8) ?? "Unable to decode response"
                throw FirebaseMessagingError.networkError(NSError(domain: "FCM", code: Int(response.status.code), userInfo: [
                    NSLocalizedDescriptionKey: "HTTP \(response.status.code)",
                    NSLocalizedFailureReasonErrorKey: "Raw response: \(rawResponse)"
                ]))
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
