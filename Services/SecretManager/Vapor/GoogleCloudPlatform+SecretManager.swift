//
//  GoogleCloudPlatform+SecretManager.swift
//  GoogleCloud
//
//  Vapor 4.x integration for Google Cloud Secret Manager
//

import Vapor
import CloudCore
import SecretManager
import AsyncHTTPClient

// MARK: - Application Extension

extension Application.GoogleCloudPlatform {
    
    public struct SecretManagerClientKey: StorageKey, LockKey {
        public typealias Value = GoogleCloudSecretManagerClient
    }
    
    private struct SecretManagerConfigurationKey: StorageKey {
        typealias Value = GoogleCloudSecretManagerConfiguration
    }
    
    private struct SecretManagerHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    /// Configuration for Cloud Secret Manager API
    public var secretManagerConfiguration: GoogleCloudSecretManagerConfiguration {
        get {
            guard let config = application.storage[SecretManagerConfigurationKey.self] else {
                fatalError("Cloud Secret Manager configuration has not been set. Use app.googleCloud.secretManagerConfiguration = ...")
            }
            return config
        }
        nonmutating set {
            guard application.storage[SecretManagerConfigurationKey.self] == nil else {
                fatalError("Attempting to override Secret Manager configuration after being set is not allowed.")
            }
            application.storage[SecretManagerConfigurationKey.self] = newValue
        }
    }
    
    /// HTTP Client для Secret Manager
    public var secretManagerHTTPClient: HTTPClient {
        if let existing = application.storage[SecretManagerHTTPClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: SecretManagerHTTPClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = application.storage[SecretManagerHTTPClientKey.self] {
            return existing
        }
        
        let new = HTTPClient(
            eventLoopGroupProvider: .shared(application.eventLoopGroup),
            configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
        )
        
        application.storage.set(SecretManagerHTTPClientKey.self, to: new) {
            try? $0.syncShutdown()
        }
        
        return new
    }
    
    /// Получить или создать Secret Manager клиент (async, thread-safe)
    public func googleCloudSecretManager() async throws -> GoogleCloudSecretManagerClient {
        if let existing = application.storage[SecretManagerClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: SecretManagerClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = application.storage[SecretManagerClientKey.self] {
            return existing
        }
        
        let client = try await GoogleCloudSecretManagerClient(
            strategy: credentials.strategy,
            client: secretManagerHTTPClient,
            scope: secretManagerConfiguration.scope as! [GoogleCloudSecretManagerScope]
        )
        
        application.storage[SecretManagerClientKey.self] = client
        application.logger.info("✅ Google Cloud Secret Manager client initialized")
        
        return client
    }
}

// MARK: - Request Extension

extension Request {
    
    /// Получить Google Cloud Secret Manager клиент
    public func googleCloudSecretManager() async throws -> GoogleCloudSecretManagerClient {
        try await application.googleCloud.googleCloudSecretManager()
    }
}

// MARK: - Lifecycle Handler

public struct GoogleCloudSecretManagerLifecycle: LifecycleHandler {
    public init() {}
    
    public func didBoot(_ application: Application) throws {
        Task.detached(priority: .high) {
            do {
                _ = try await application.googleCloud.googleCloudSecretManager()
                application.logger.info("✅ Google Cloud Secret Manager pre-initialized")
            } catch {
                application.logger.warning("⚠️ Google Cloud Secret Manager pre-initialization failed: \(error)")
            }
        }
    }
    
    public func shutdown(_ application: Application) {
        application.logger.info("Shutting down Google Cloud Secret Manager")
    }
}

