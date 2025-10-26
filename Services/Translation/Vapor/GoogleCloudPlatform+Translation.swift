//
//  GoogleCloudPlatform+Translation.swift
//  GoogleCloud
//
//  Vapor 4.x integration for Google Cloud Translation
//

import Vapor
import CloudCore
import Translation
import AsyncHTTPClient

// MARK: - Application Extension

extension Application.GoogleCloudPlatform {
    
    public struct TranslationClientKey: StorageKey, LockKey {
        public typealias Value = GoogleCloudTranslationClient
    }
    
    private struct TranslationConfigurationKey: StorageKey {
        typealias Value = GoogleCloudTranslationConfiguration
    }
    
    private struct TranslationHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    /// Configuration for Cloud Translation API
    public var translationConfiguration: GoogleCloudTranslationConfiguration {
        get {
            guard let config = application.storage[TranslationConfigurationKey.self] else {
                fatalError("Cloud Translation configuration has not been set. Use app.googleCloud.translationConfiguration = ...")
            }
            return config
        }
        nonmutating set {
            guard application.storage[TranslationConfigurationKey.self] == nil else {
                fatalError("Attempting to override Translation configuration after being set is not allowed.")
            }
            application.storage[TranslationConfigurationKey.self] = newValue
        }
    }
    
    /// HTTP Client для Translation
    public var translationHTTPClient: HTTPClient {
        if let existing = application.storage[TranslationHTTPClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: TranslationHTTPClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = application.storage[TranslationHTTPClientKey.self] {
            return existing
        }
        
        let new = HTTPClient(
            eventLoopGroupProvider: .shared(application.eventLoopGroup),
            configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
        )
        
        application.storage.set(TranslationHTTPClientKey.self, to: new) {
            try? $0.syncShutdown()
        }
        
        return new
    }
    
    /// Получить или создать Translation клиент (async, thread-safe)
    public func googleCloudTranslation() async throws -> GoogleCloudTranslationClient {
        if let existing = application.storage[TranslationClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: TranslationClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        if let existing = application.storage[TranslationClientKey.self] {
            return existing
        }
        
        let client = try await GoogleCloudTranslationClient(
            strategy: credentials.strategy,
            client: translationHTTPClient,
            scope: translationConfiguration.scope as! [GoogleCloudTranslationScope]
        )
        
        application.storage[TranslationClientKey.self] = client
        application.logger.info("✅ Google Cloud Translation client initialized")
        
        return client
    }
}

// MARK: - Request Extension

extension Request {
    
    /// Получить Google Cloud Translation клиент
    public func googleCloudTranslation() async throws -> GoogleCloudTranslationClient {
        try await application.googleCloud.googleCloudTranslation()
    }
}

// MARK: - Lifecycle Handler

public struct GoogleCloudTranslationLifecycle: LifecycleHandler {
    public init() {}
    
    public func didBoot(_ application: Application) throws {
        Task.detached(priority: .high) {
            do {
                _ = try await application.googleCloud.googleCloudTranslation()
                application.logger.info("✅ Google Cloud Translation pre-initialized")
            } catch {
                application.logger.warning("⚠️ Google Cloud Translation pre-initialization failed: \(error)")
            }
        }
    }
    
    public func shutdown(_ application: Application) {
        application.logger.info("Shutting down Google Cloud Translation")
    }
}

