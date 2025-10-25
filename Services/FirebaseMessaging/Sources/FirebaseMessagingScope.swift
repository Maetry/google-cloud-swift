//
//  FirebaseMessagingScope.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Foundation
import Core

public enum GoogleCloudFirebaseMessagingScope: String, CaseIterable, GoogleCloudAPIScope {
    case messaging = "https://www.googleapis.com/auth/firebase.messaging"
    
    public var value: String {
        return self.rawValue
    }
}
