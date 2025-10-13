//
//  GoogleCloudPlatform+Datastore.swift
//  GoogleCloud
//
//  Vapor 4.x integration for Google Cloud Datastore
//

import Vapor
import Core
import Datastore
import AsyncHTTPClient

// MARK: - Application Extension

extension Application.GoogleCloudPlatform {
    
    public struct DatastoreClientKey: StorageKey, LockKey {
        public typealias Value = GoogleCloudDatastoreClient
    }
    
    private struct DatastoreConfigurationKey: StorageKey {
        typealias Value = GoogleCloudDatastoreConfiguration
    }
    
    private struct DatastoreHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    private struct DatastoreBaseKey: StorageKey {
        typealias Value = String
    }
    
    /// Configuration for Cloud Datastore API
    public var datastoreConfiguration: GoogleCloudDatastoreConfiguration {
        get {
            guard let config = application.storage[DatastoreConfigurationKey.self] else {
                fatalError("Cloud Datastore configuration has not been set. Use app.googleCloud.datastoreConfiguration = ...")
            }
            return config
        }
        nonmutating set {
            guard application.storage[DatastoreConfigurationKey.self] == nil else {
                fatalError("Attempting to override Datastore configuration after being set is not allowed.")
            }
            application.storage[DatastoreConfigurationKey.self] = newValue
        }
    }
    
    /// Base URL for Datastore API
    public var datastoreBase: String {
        get {
            if let base = application.storage[DatastoreBaseKey.self] {
                return base
            } else {
                return "https://datastore.googleapis.com"
            }
        }
        
        set {
            guard application.storage[DatastoreBaseKey.self] == nil else {
                fatalError("Attempting to override configuration after being set is not allowed.")
            }
            application.storage[DatastoreBaseKey.self] = newValue
        }
    }
    
    /// HTTP Client для Datastore
    public var datastoreHTTPClient: HTTPClient {
        if let existing = application.storage[DatastoreHTTPClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: DatastoreHTTPClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = application.storage[DatastoreHTTPClientKey.self] {
            return existing
        }
        
        let new = HTTPClient(
            eventLoopGroupProvider: .shared(application.eventLoopGroup),
            configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
        )
        
        application.storage.set(DatastoreHTTPClientKey.self, to: new) {
            try? $0.syncShutdown()
        }
        
        return new
    }
    
    /// Получить или создать Datastore клиент (async, thread-safe)
    public func googleCloudDatastore() async throws -> GoogleCloudDatastoreClient {
        if let existing = application.storage[DatastoreClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: DatastoreClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = application.storage[DatastoreClientKey.self] {
            return existing
        }
        
        let client = try await GoogleCloudDatastoreClient(
            strategy: credentials.strategy,
            client: datastoreHTTPClient,
            base: datastoreBase,
            scope: datastoreConfiguration.scope as! [GoogleCloudDatastoreScope]
        )
        
        application.storage[DatastoreClientKey.self] = client
        application.logger.info("✅ Google Cloud Datastore client initialized")
        
        return client
    }
}

// MARK: - Request Extension

extension Request {
    
    /// Получить Google Cloud Datastore клиент
    public func googleCloudDatastore() async throws -> GoogleCloudDatastoreClient {
        try await application.googleCloud.googleCloudDatastore()
    }
}

// MARK: - Lifecycle Handler

public struct GoogleCloudDatastoreLifecycle: LifecycleHandler {
    public init() {}
    
    public func didBoot(_ application: Application) throws {
        Task.detached(priority: .high) {
            do {
                _ = try await application.googleCloud.googleCloudDatastore()
                application.logger.info("✅ Google Cloud Datastore pre-initialized")
            } catch {
                application.logger.warning("⚠️ Google Cloud Datastore pre-initialization failed: \(error)")
            }
        }
    }
    
    public func shutdown(_ application: Application) {
        application.logger.info("Shutting down Google Cloud Datastore")
    }
}

