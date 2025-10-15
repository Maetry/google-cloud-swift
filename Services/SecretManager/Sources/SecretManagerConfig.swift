import Core

public struct GoogleCloudSecretManagerConfiguration: GoogleCloudAPIConfiguration, Sendable {
    public var scope: [any GoogleCloudAPIScope]
    public let serviceAccount: String
    public let project: String?
    
    public init(scope: [GoogleCloudSecretManagerScope], serviceAccount: String = "default", project: String? = nil) {
        self.scope = scope
        self.serviceAccount = serviceAccount
        self.project = project
    }
    
    /// Create a new `GoogleCloudSecretManagerConfiguration` with cloud platform scope and the default service account.
    public static func `default`() -> GoogleCloudSecretManagerConfiguration {
        return GoogleCloudSecretManagerConfiguration(scope: [.cloudPlatform],
                                                     serviceAccount: "default",
                                                     project: nil)
    }
}

public enum GoogleCloudSecretManagerScope: GoogleCloudAPIScope, Sendable {
    case cloudPlatform
    
    public var value: String {
        switch self {
        case .cloudPlatform: return "https://www.googleapis.com/auth/cloud-platform"
        }
    }
}

