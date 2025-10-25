//
//  FirebaseMessagingConfig.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Core
import Foundation

public struct GoogleCloudFirebaseMessagingConfiguration: GoogleCloudAPIConfiguration, Sendable {
    public var scope: [any GoogleCloudAPIScope]
    public let serviceAccount: String
    public let project: String?
    
    public init(scope: [GoogleCloudFirebaseMessagingScope], serviceAccount: String = "default", project: String? = nil) {
        self.scope = scope
        self.serviceAccount = serviceAccount
        self.project = project
    }
    
    /// Create a new `GoogleCloudFirebaseMessagingConfiguration` with messaging scope and the default service account.
    public static func `default`() -> GoogleCloudFirebaseMessagingConfiguration {
        return GoogleCloudFirebaseMessagingConfiguration(scope: [.messaging],
                                                           serviceAccount: "default",
                                                           project: nil)
    }
}
