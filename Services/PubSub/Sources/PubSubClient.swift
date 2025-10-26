import CloudCore
import Foundation
import AsyncHTTPClient

public struct GoogleCloudPubSubClient: Sendable {
    public var pubSubTopic: TopicsAPI
    public var pubSubSubscription: SubscriptionsAPI
    let pubSubRequest: GoogleCloudPubSubRequest
    
    public init(strategy: CredentialsLoadingStrategy,
                client: HTTPClient,
                base: String = "https://pubsub.googleapis.com",
                scope: [GoogleCloudPubSubScope]) async throws {
        let resolvedCredentials = try await CredentialsResolver.resolveCredentials(strategy: strategy)
        
        switch resolvedCredentials {
        case .gcloud(let gCloudCredentials):
            let provider = GCloudCredentialsProvider(client: client, credentials: gCloudCredentials)
            pubSubRequest = .init(tokenProvider: provider, client: client, project: gCloudCredentials.quotaProjectId)
            
        case .serviceAccount(let serviceAccountCredentials):
            let provider = ServiceAccountCredentialsProvider(client: client, credentials: serviceAccountCredentials, scope: scope)
            pubSubRequest = .init(tokenProvider: provider, client: client, project: serviceAccountCredentials.projectId)
            
        case .computeEngine(let metadataUrl):
            let projectId = ProcessInfo.processInfo.environment["PROJECT_ID"] ?? 
                          ProcessInfo.processInfo.environment["GOOGLE_PROJECT_ID"] ?? "default"
            switch strategy {
            case .computeEngine(let client):
                let provider = ComputeEngineCredentialsProvider(client: client, scopes: scope, url: metadataUrl)
                pubSubRequest = .init(tokenProvider: provider, client: client, project: projectId)
            default:
                let provider = ComputeEngineCredentialsProvider(client: client, scopes: scope, url: metadataUrl)
                pubSubRequest = .init(tokenProvider: provider, client: client, project: projectId)
            }
        }
        
        pubSubTopic = GoogleCloudPubSubTopicsAPI(request: pubSubRequest, endpoint: base)
        pubSubSubscription = GoogleCloudPubSubSubscriptionsAPI(request: pubSubRequest, endpoint: base)
    }
}

