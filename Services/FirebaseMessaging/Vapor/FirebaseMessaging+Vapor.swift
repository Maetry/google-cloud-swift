//
//  FirebaseMessaging+Vapor.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Vapor
import CloudCore
import FirebaseMessaging

extension Application {
    /// Firebase Messaging клиент
    public var firebaseMessaging: GoogleCloudFirebaseMessagingClient {
        get {
            guard let client = storage[FirebaseMessagingClientKey.self] else {
                fatalError("Firebase Messaging client not configured. Use app.firebaseMessaging = ...")
            }
            return client
        }
        set {
            storage[FirebaseMessagingClientKey.self] = newValue
        }
    }
}

private struct FirebaseMessagingClientKey: StorageKey {
    typealias Value = GoogleCloudFirebaseMessagingClient
}

extension Request {
    /// Firebase Messaging клиент для запроса
    public var firebaseMessaging: GoogleCloudFirebaseMessagingClient {
        return application.firebaseMessaging
    }
}
