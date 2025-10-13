//
//  GoogleCloudAPIClient.swift
//  GoogleCloudKit
//
//  Created by Andrew Edwards on 8/5/19.
//

import Foundation
import AsyncHTTPClient

public protocol GoogleCloudAPIClient {
    var tokenProvider: AccessTokenProvider { get }
}

/// Protocol for each GoogleCloud API configuration.
public protocol GoogleCloudAPIConfiguration {
    var scope: [any GoogleCloudAPIScope] { get }
    var serviceAccount: String { get }
    var project: String? { get }
}

/// Protocol for each GoogleCloud API scope.
public protocol GoogleCloudAPIScope {
    var value: String { get }
}