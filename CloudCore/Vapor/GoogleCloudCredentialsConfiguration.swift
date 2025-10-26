//
//  GoogleCloudCredentialsConfiguration.swift
//  GoogleCloud
//
//  Created by Andrew Edwards on 4/17/18.
//

import Foundation
import CloudCore

/// Configuration for Google Cloud credentials that bridges old API to new CredentialsLoadingStrategy
public struct GoogleCloudCredentialsConfiguration: Sendable {
    public let project: String?
    private let credentialsFile: String?
    
    public init(project: String? = nil, credentialsFile: String? = nil) {
        self.project = project
        self.credentialsFile = credentialsFile
    }
    
    /// Converts to the new CredentialsLoadingStrategy
    public var strategy: CredentialsLoadingStrategy {
        if let path = credentialsFile {
            // Try to determine type by loading file
            return .filePath(path, .serviceAccount)
        } else if let envJSON = ProcessInfo.processInfo.environment["GOOGLE_APPLICATION_CREDENTIALS"],
                  envJSON.starts(with: "{") {
            return .environmentJSON
        } else {
            return .environment
        }
    }
}

