//
//  FirebaseMessagingClient.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import CloudCore
import Foundation
import AsyncHTTPClient
import NIO

public struct GoogleCloudFirebaseMessagingClient: Sendable {
    public var messaging: FirebaseMessagingAPI
    
    let firebaseMessagingRequest: GoogleCloudFirebaseMessagingRequest
    
    public init(strategy: CredentialsLoadingStrategy,
                client: HTTPClient,
                base: String = "https://fcm.googleapis.com",
                scope: [GoogleCloudFirebaseMessagingScope]) async throws {
        let resolvedCredentials = try await CredentialsResolver.resolveCredentials(strategy: strategy)
        
        switch resolvedCredentials {
        case .gcloud(let gCloudCredentials):
            let provider = GCloudCredentialsProvider(client: client, credentials: gCloudCredentials)
            firebaseMessagingRequest = .init(tokenProvider: provider, client: client, project: gCloudCredentials.quotaProjectId)
            
        case .serviceAccount(let serviceAccountCredentials):
            let provider = ServiceAccountCredentialsProvider(client: client,
                                                             credentials: serviceAccountCredentials,
                                                             scope: scope)
            firebaseMessagingRequest = .init(tokenProvider: provider, client: client, project: serviceAccountCredentials.projectId)
            
        case .computeEngine(let metadataUrl):
            let projectId = ProcessInfo.processInfo.environment["PROJECT_ID"] ?? 
                          ProcessInfo.processInfo.environment["GOOGLE_PROJECT_ID"] ?? "default"
            switch strategy {
            case .computeEngine(let client):
                let provider = ComputeEngineCredentialsProvider(client: client, scopes: scope, url: metadataUrl)
                firebaseMessagingRequest = .init(tokenProvider: provider, client: client, project: projectId)
            default:
                let provider = ComputeEngineCredentialsProvider(client: client, scopes: scope, url: metadataUrl)
                firebaseMessagingRequest = .init(tokenProvider: provider, client: client, project: projectId)
            }
        }
        
        messaging = GoogleCloudFirebaseMessagingAPI(request: firebaseMessagingRequest, endpoint: base)
    }
}
