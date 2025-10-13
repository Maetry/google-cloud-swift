//
//  GoogleCloudPlatform+Application.swift
//  GoogleCloud
//
//  Created by Andrew Edwards on 4/17/18.
//

import Vapor

extension Application {
    public var googleCloud: GoogleCloudPlatform {
        .init(application: self)
    }
    
    private struct CloudCredentialsKey: StorageKey {
        typealias Value = GoogleCloudCredentialsConfiguration
    }
    
    public struct GoogleCloudPlatform {
        public let application: Application
        
        /// The configuration for authenticating to GCP APIs via credentials
        public var credentials: GoogleCloudCredentialsConfiguration {
            get {
                if let credentials = application.storage[CloudCredentialsKey.self] {
                   return credentials
                } else {
                    fatalError("Cloud credentials configuration has not been set. Use app.googleCloud.credentials = ...")
                }
            }
            nonmutating set {
                if application.storage[CloudCredentialsKey.self] == nil {
                   application.storage[CloudCredentialsKey.self] = newValue
                } else {
                    fatalError("Overriding credentials configuration after being set is not allowed.")
                }
            }
        }
    }
}

