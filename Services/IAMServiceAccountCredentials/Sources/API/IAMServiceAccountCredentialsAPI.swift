import AsyncHTTPClient
import Foundation
import JWTKit

public protocol IAMServiceAccountCredentialsAPI: Sendable {
    func signJWT(_ jwt: JWTPayload, delegates: [String], serviceAccount: String) async throws -> SignJWTResponse
}

public extension IAMServiceAccountCredentialsAPI {
    func signJWT(_ jwt: JWTPayload, delegates: [String] = [], serviceAccount: String) async throws -> SignJWTResponse {
        try await signJWT(jwt, delegates: delegates, serviceAccount: serviceAccount)
    }
}

public final class GoogleCloudServiceAccountCredentialsAPI: IAMServiceAccountCredentialsAPI {
    
    let endpoint: String
    let request: IAMServiceAccountCredentialsRequest
    private let encoder = JSONEncoder()
    
    init(request: IAMServiceAccountCredentialsRequest,
         endpoint: String) {
        self.request = request
        self.endpoint = endpoint
    }
    
    public func signJWT(_ jwt: JWTPayload, delegates: [String] = [], serviceAccount: String) async throws -> SignJWTResponse {
        let signJWTRequest = try SignJWTRequest(jwt: jwt, delegates: delegates)
        let body = try HTTPClientRequest.Body.bytes(.init(data: encoder.encode(signJWTRequest)))
        
        return try await request.send(method: .POST, path: "\(endpoint)/v1/projects/-/serviceAccounts/\(serviceAccount):signJwt", body: body)
    }
}

