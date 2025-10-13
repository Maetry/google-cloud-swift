// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "google-cloud",
    platforms: [
        .macOS(.v13),
        .iOS(.v13)
    ],
    products: [
        // Core library
        .library(
            name: "GoogleCloudCore",
            targets: ["Core"]
        ),
        // Individual service libraries
        .library(
            name: "GoogleCloudStorage",
            targets: ["Storage"]
        ),
        .library(
            name: "GoogleCloudDatastore",
            targets: ["Datastore"]
        ),
        .library(
            name: "GoogleCloudSecretManager",
            targets: ["SecretManager"]
        ),
        .library(
            name: "GoogleCloudTranslation",
            targets: ["Translation"]
        ),
        .library(
            name: "GoogleCloudPubSub",
            targets: ["PubSub"]
        ),
        .library(
            name: "GoogleCloudIAMServiceAccountCredentials",
            targets: ["IAMServiceAccountCredentials"]
        ),
        // Combined library with all services
        .library(
            name: "GoogleCloudKit",
            targets: [
                "Core",
                "Storage",
                "Datastore",
                "SecretManager",
                "Translation",
                "PubSub",
                "IAMServiceAccountCredentials"
            ]
        ),
        // Vapor integration (optional) - отдельные продукты для модульности
        .library(
            name: "VaporGoogleCloudCore",
            targets: ["VaporGoogleCloudCore"]),
        .library(
            name: "VaporGoogleCloudStorage",
            targets: ["VaporGoogleCloudCore", "VaporGoogleCloudStorage"]),
        .library(
            name: "VaporGoogleCloudDatastore",
            targets: ["VaporGoogleCloudCore", "VaporGoogleCloudDatastore"]),
        .library(
            name: "VaporGoogleCloudPubSub",
            targets: ["VaporGoogleCloudCore", "VaporGoogleCloudPubSub"]),
        .library(
            name: "VaporGoogleCloudSecretManager",
            targets: ["VaporGoogleCloudCore", "VaporGoogleCloudSecretManager"]),
        .library(
            name: "VaporGoogleCloudTranslation",
            targets: ["VaporGoogleCloudCore", "VaporGoogleCloudTranslation"]),
    ],
    dependencies: [
        // Core dependencies for Google Cloud services
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.18.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "5.2.0"),
        // Vapor for integration layer (optional)
        .package(url: "https://github.com/vapor/vapor.git", from: "4.117.0"),
    ],
    targets: [
        // Core module - contains authentication and shared utilities
        .target(
            name: "Core",
            dependencies: [
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ],
            path: "Core/Sources/"
        ),
        
        // Service modules
        .target(
            name: "Storage",
            dependencies: [
                .target(name: "Core")
            ],
            path: "Services/Storage/Sources/"
        ),
        .target(
            name: "Datastore",
            dependencies: [
                .target(name: "Core")
            ],
            path: "Services/Datastore/Sources/"
        ),
        .target(
            name: "SecretManager",
            dependencies: [
                .target(name: "Core")
            ],
            path: "Services/SecretManager/Sources"
        ),
        .target(
            name: "Translation",
            dependencies: [
                .target(name: "Core")
            ],
            path: "Services/Translation/Sources"
        ),
        .target(
            name: "PubSub",
            dependencies: [
                .target(name: "Core")
            ],
            path: "Services/PubSub/Sources/"
        ),
        .target(
            name: "IAMServiceAccountCredentials",
            dependencies: [
                .target(name: "Core")
            ],
            path: "Services/IAMServiceAccountCredentials/Sources"
        ),
        
        // Vapor integration targets (модульные)
        .target(
            name: "VaporGoogleCloudCore",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "Core"),
            ],
            path: "Core/Vapor/"
        ),
        .target(
            name: "VaporGoogleCloudStorage",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "Storage"),
                .target(name: "VaporGoogleCloudCore"),
            ],
            path: "Services/Storage/Vapor/"
        ),
        .target(
            name: "VaporGoogleCloudDatastore",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "Datastore"),
                .target(name: "VaporGoogleCloudCore"),
            ],
            path: "Services/Datastore/Vapor/"
        ),
        .target(
            name: "VaporGoogleCloudPubSub",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "PubSub"),
                .target(name: "VaporGoogleCloudCore"),
            ],
            path: "Services/PubSub/Vapor/"
        ),
        .target(
            name: "VaporGoogleCloudSecretManager",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "SecretManager"),
                .target(name: "VaporGoogleCloudCore"),
            ],
            path: "Services/SecretManager/Vapor/"
        ),
        .target(
            name: "VaporGoogleCloudTranslation",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "Translation"),
                .target(name: "VaporGoogleCloudCore"),
            ],
            path: "Services/Translation/Vapor/"
        ),
        
        // Test targets
        .testTarget(
            name: "CoreTests",
            dependencies: [
                .target(name: "Core"),
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ],
            path: "Tests/CoreTests/"
        ),
        .testTarget(
            name: "StorageTests",
            dependencies: [
                .target(name: "Storage")
            ],
            path: "Tests/StorageTests/"
        ),
        .testTarget(
            name: "DatastoreTests",
            dependencies: [
                .target(name: "Datastore")
            ],
            path: "Tests/DatastoreTests/"
        ),
        .testTarget(
            name: "TranslationTests",
            dependencies: [
                .target(name: "Translation")
            ],
            path: "Tests/TranslationTests/"
        ),
        .testTarget(
            name: "PubSubTests",
            dependencies: [
                .target(name: "PubSub")
            ],
            path: "Tests/PubSubTests/"
        ),
    ]
)
