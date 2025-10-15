import Core

public struct GoogleCloudTranslationConfiguration: GoogleCloudAPIConfiguration, Sendable {
    public var scope: [any GoogleCloudAPIScope]
    public let serviceAccount: String
    public let project: String?
    
    public init(scope: [GoogleCloudTranslationScope], serviceAccount: String = "default", project: String? = nil) {
        self.scope = scope
        self.serviceAccount = serviceAccount
        self.project = project
    }
    
    /// Create a new `GoogleCloudTranslationConfiguration` with cloud platform scope and the default service account.
    public static func `default`() -> GoogleCloudTranslationConfiguration {
        return GoogleCloudTranslationConfiguration(scope: [.cloudPlatform],
                                                   serviceAccount: "default",
                                                   project: nil)
    }
}

