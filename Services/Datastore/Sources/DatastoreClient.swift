import Core
import Foundation
import AsyncHTTPClient

public struct GoogleCloudDatastoreClient: Sendable {
    
    public var project: DatastoreProjectAPI
    let datastoreRequest: GoogleCloudDatastoreRequest
    
    /// Initialize a client for interacting with the Google Cloud Datastore API
    /// - Parameters:
    ///   - strategy: The credentials loading strategy
    ///   - client: An `HTTPClient` used for making API requests
    ///   - base: The base URL to use for the Datastore API
    ///   - scope: The scope for the Datastore API
    public init(strategy: CredentialsLoadingStrategy,
                client: HTTPClient,
                base: String = "https://datastore.googleapis.com",
                scope: [GoogleCloudDatastoreScope]) async throws {
        let resolvedCredentials = try await CredentialsResolver.resolveCredentials(strategy: strategy)
        
        switch resolvedCredentials {
        case .gcloud(let gCloudCredentials):
            let provider = GCloudCredentialsProvider(client: client, credentials: gCloudCredentials)
            datastoreRequest = .init(tokenProvider: provider, client: client, project: gCloudCredentials.quotaProjectId)
            
        case .serviceAccount(let serviceAccountCredentials):
            let provider = ServiceAccountCredentialsProvider(client: client, credentials: serviceAccountCredentials, scope: scope)
            datastoreRequest = .init(tokenProvider: provider, client: client, project: serviceAccountCredentials.projectId)
            
        case .computeEngine(let metadataUrl):
            let projectId = ProcessInfo.processInfo.environment["PROJECT_ID"] ?? 
                          ProcessInfo.processInfo.environment["GOOGLE_PROJECT_ID"] ?? "default"
            switch strategy {
            case .computeEngine(let client):
                let provider = ComputeEngineCredentialsProvider(client: client, scopes: scope, url: metadataUrl)
                datastoreRequest = .init(tokenProvider: provider, client: client, project: projectId)
            default:
                let provider = ComputeEngineCredentialsProvider(client: client, scopes: scope, url: metadataUrl)
                datastoreRequest = .init(tokenProvider: provider, client: client, project: projectId)
            }
        }
        
        project = GoogleCloudDatastoreProjectAPI(request: datastoreRequest, endpoint: base)
    }
}

