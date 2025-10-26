//
//  GoogleCloudAPIConfiguration.swift
//  GoogleCloud
//
//  Created by Andrew Edwards on 11/15/18.
//

import Foundation
import CloudCore

/// Protocol for each GoogleCloud API configuration.
public protocol GoogleCloudAPIConfiguration {
    var scope: [any GoogleCloudAPIScope] { get }
    var serviceAccount: String { get }
    var project: String? { get }
}

