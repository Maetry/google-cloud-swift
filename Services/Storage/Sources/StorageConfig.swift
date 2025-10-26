//
//  StorageConfig.swift
//  GoogleCloudKit
//
//  Created by Andrew Edwards on 4/21/18.
//

import CloudCore
import Foundation

public struct GoogleCloudStorageConfiguration: GoogleCloudAPIConfiguration, Sendable {
    public var scope: [any GoogleCloudAPIScope]
    public let serviceAccount: String
    public let project: String?
    
    public init(scope: [GoogleCloudStorageScope], serviceAccount: String = "default", project: String? = nil) {
        self.scope = scope
        self.serviceAccount = serviceAccount
        self.project = project
    }
    
    /// Create a new `GoogleCloudStorageConfiguration` with full control scope and the default service account.
    public static func `default`() -> GoogleCloudStorageConfiguration {
        return GoogleCloudStorageConfiguration(scope: [.fullControl],
                                               serviceAccount: "default",
                                               project: nil)
    }
}

