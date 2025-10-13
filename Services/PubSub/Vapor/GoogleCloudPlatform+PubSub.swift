//
//  GoogleCloudPlatform+PubSub.swift
//  GoogleCloud
//
//  Vapor 4.x integration for Google Cloud Pub/Sub
//

import Vapor
import Core
import PubSub
import AsyncHTTPClient

// MARK: - Application Extension

extension Application.GoogleCloudPlatform {
    
    public struct PubSubClientKey: StorageKey, LockKey {
        public typealias Value = GoogleCloudPubSubClient
    }
    
    private struct PubSubConfigurationKey: StorageKey {
        typealias Value = GoogleCloudPubSubConfiguration
    }
    
    private struct PubSubHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    /// Configuration for Cloud Pub/Sub API
    public var pubsubConfiguration: GoogleCloudPubSubConfiguration {
        get {
            guard let config = application.storage[PubSubConfigurationKey.self] else {
                fatalError("Cloud Pub/Sub configuration has not been set. Use app.googleCloud.pubsubConfiguration = ...")
            }
            return config
        }
        nonmutating set {
            guard application.storage[PubSubConfigurationKey.self] == nil else {
                fatalError("Attempting to override Pub/Sub configuration after being set is not allowed.")
            }
            application.storage[PubSubConfigurationKey.self] = newValue
        }
    }
    
    /// HTTP Client для Pub/Sub
    public var pubsubHTTPClient: HTTPClient {
        if let existing = application.storage[PubSubHTTPClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: PubSubHTTPClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = application.storage[PubSubHTTPClientKey.self] {
            return existing
        }
        
        let new = HTTPClient(
            eventLoopGroupProvider: .shared(application.eventLoopGroup),
            configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
        )
        
        application.storage.set(PubSubHTTPClientKey.self, to: new) {
            try? $0.syncShutdown()
        }
        
        return new
    }
    
    /// Получить или создать Pub/Sub клиент (async, thread-safe)
    public func googleCloudPubSub() async throws -> GoogleCloudPubSubClient {
        if let existing = application.storage[PubSubClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: PubSubClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = application.storage[PubSubClientKey.self] {
            return existing
        }
        
        let client = try await GoogleCloudPubSubClient(
            strategy: credentials.strategy,
            client: pubsubHTTPClient,
            scope: pubsubConfiguration.scope as! [GoogleCloudPubSubScope]
        )
        
        application.storage[PubSubClientKey.self] = client
        application.logger.info("✅ Google Cloud Pub/Sub client initialized")
        
        return client
    }
}

// MARK: - Request Extension

extension Request {
    
    /// Получить Google Cloud Pub/Sub клиент
    public func googleCloudPubSub() async throws -> GoogleCloudPubSubClient {
        try await application.googleCloud.googleCloudPubSub()
    }
}

// MARK: - Lifecycle Handler

public struct GoogleCloudPubSubLifecycle: LifecycleHandler {
    public init() {}
    
    public func didBoot(_ application: Application) throws {
        Task.detached(priority: .high) {
            do {
                _ = try await application.googleCloud.googleCloudPubSub()
                application.logger.info("✅ Google Cloud Pub/Sub pre-initialized")
            } catch {
                application.logger.warning("⚠️ Google Cloud Pub/Sub pre-initialization failed: \(error)")
            }
        }
    }
    
    public func shutdown(_ application: Application) {
        application.logger.info("Shutting down Google Cloud Pub/Sub")
    }
}

