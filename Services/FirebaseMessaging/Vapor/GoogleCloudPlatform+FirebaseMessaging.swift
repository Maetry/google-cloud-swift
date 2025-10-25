//
//  GoogleCloudPlatform+FirebaseMessaging.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Vapor
import Core
import FirebaseMessaging

/// Настроить Firebase Messaging
public func configureFirebaseMessaging(
    _ app: Application,
    strategy: CredentialsLoadingStrategy,
    scope: [GoogleCloudFirebaseMessagingScope] = [.messaging],
    base: String = "https://fcm.googleapis.com"
) async throws {
    let client = try await GoogleCloudFirebaseMessagingClient(
        strategy: strategy,
        client: app.http.client.shared,
        base: base,
        scope: scope
    )
    
    app.firebaseMessaging = client
}
