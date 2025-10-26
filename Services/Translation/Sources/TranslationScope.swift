import CloudCore

public enum GoogleCloudTranslationScope: GoogleCloudAPIScope, CaseIterable, Sendable {
    case cloudPlatform
    case cloudTranslation

    public var value: String {
        switch self {
        case .cloudPlatform: return "https://www.googleapis.com/auth/cloud-platform"
        case .cloudTranslation: return "https://www.googleapis.com/auth/cloud-translation"
        }
    }
}
