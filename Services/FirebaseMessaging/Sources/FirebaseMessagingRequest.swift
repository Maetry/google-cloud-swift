//
//  FirebaseMessagingRequest.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import Core
import Foundation
import AsyncHTTPClient
import NIO

public struct GoogleCloudFirebaseMessagingRequest: Sendable {
    let tokenProvider: AccessTokenProvider
    let client: HTTPClient
    let project: String
    
    public init(tokenProvider: AccessTokenProvider, client: HTTPClient, project: String) {
        self.tokenProvider = tokenProvider
        self.client = client
        self.project = project
    }
}
