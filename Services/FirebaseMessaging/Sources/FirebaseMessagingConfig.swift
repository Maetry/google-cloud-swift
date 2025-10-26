//
//  FirebaseMessagingConfig.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import CloudCore
import Foundation

public struct GoogleCloudFirebaseMessagingConfiguration: GoogleCloudAPIConfiguration, Sendable {
    public var scope: [any GoogleCloudAPIScope] {
        return _scope.map { $0 as any GoogleCloudAPIScope }
    }
    
    internal let _scope: [GoogleCloudFirebaseMessagingScope]
    public let serviceAccount: String
    public let project: String?
    public let base: String
    
    public init(scope: [GoogleCloudFirebaseMessagingScope], serviceAccount: String = "default", project: String? = nil, base: String = "https://fcm.googleapis.com") {
        self._scope = scope
        self.serviceAccount = serviceAccount
        self.project = project
        self.base = base
    }
    
    /// Получить scope как конкретный тип для внутреннего использования
    public var concreteScope: [GoogleCloudFirebaseMessagingScope] {
        return _scope
    }
    
    /// Create a new `GoogleCloudFirebaseMessagingConfiguration` with messaging scope and the default service account.
    public static func `default`() -> GoogleCloudFirebaseMessagingConfiguration {
        return GoogleCloudFirebaseMessagingConfiguration(scope: [.messaging],
                                                           serviceAccount: "default",
                                                           project: nil)
    }
}
