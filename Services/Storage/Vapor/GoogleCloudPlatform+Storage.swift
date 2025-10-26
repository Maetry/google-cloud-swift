//
//  GoogleCloudPlatform+Storage.swift
//  GoogleCloud
//
//  Improved integration following Vapor 4.x best practices
//

import Vapor
import CloudCore
import Storage
import AsyncHTTPClient

// MARK: - Application Extension

extension Application.GoogleCloudPlatform {
    
    public struct StorageClientKey: StorageKey, LockKey {
        public typealias Value = GoogleCloudStorageClient
    }
    
    private struct StorageConfigurationKey: StorageKey {
        typealias Value = GoogleCloudStorageConfiguration
    }
    
    private struct StorageHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    /// Configuration for Cloud Storage API
    public var storageConfiguration: GoogleCloudStorageConfiguration {
        get {
            guard let config = application.storage[StorageConfigurationKey.self] else {
                fatalError("Cloud Storage configuration has not been set. Use app.googleCloud.storageConfiguration = ...")
            }
            return config
        }
        nonmutating set {
            guard application.storage[StorageConfigurationKey.self] == nil else {
                fatalError("Attempting to override Storage configuration after being set is not allowed.")
            }
            application.storage[StorageConfigurationKey.self] = newValue
        }
    }
    
    /// HTTP Client для Storage (переиспользуемый)
    public var storageHTTPClient: HTTPClient {
        if let existing = application.storage[StorageHTTPClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: StorageHTTPClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        // Double-check после получения lock
        if let existing = application.storage[StorageHTTPClientKey.self] {
            return existing
        }
        
        let new = HTTPClient(
            eventLoopGroupProvider: .shared(application.eventLoopGroup),
            configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
        )
        
        application.storage.set(StorageHTTPClientKey.self, to: new) {
            try? $0.syncShutdown()
        }
        
        return new
    }
    
    /// Получить или создать Storage клиент (async, thread-safe)
    public func googleCloudStorage() async throws -> GoogleCloudStorageClient {
        // Проверка кэша
        if let existing = application.storage[StorageClientKey.self] {
            return existing
        }
        
        // Thread-safe инициализация
        let lock = application.locks.lock(for: StorageClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        // Double-check после получения lock
        if let existing = application.storage[StorageClientKey.self] {
            return existing
        }
        
        // Создаем клиент (async, без блокировки!)
        let client = try await GoogleCloudStorageClient(
            strategy: credentials.strategy,
            client: storageHTTPClient,
            scope: storageConfiguration.scope as! [GoogleCloudStorageScope]
        )
        
        application.storage[StorageClientKey.self] = client
        application.logger.info("✅ Google Cloud Storage client initialized")
        
        return client
    }
}

// MARK: - Request Extension

extension Request {
    
    /// Получить Google Cloud Storage клиент (async, thread-safe, lazy initialization)
    ///
    /// Использование:
    /// ```swift
    /// app.post("upload") { req async throws in
    ///     let storage = try await req.googleCloudStorage()
    ///     let object = try await storage.object.createSimpleUpload(...)
    /// }
    /// ```
    ///
    /// - Returns: Инициализированный GoogleCloudStorageClient
    /// - Throws: Ошибки при инициализации или отсутствии конфигурации
    public func googleCloudStorage() async throws -> GoogleCloudStorageClient {
        try await application.googleCloud.googleCloudStorage()
    }
}

// MARK: - Lifecycle Handler

/// Lifecycle handler для предварительной инициализации Google Cloud Storage
///
/// Использование в configure.swift:
/// ```
/// app.lifecycle.use(GoogleCloudStorageLifecycle())
/// ```
public struct GoogleCloudStorageLifecycle: LifecycleHandler {
    public init() {}
    
    public func didBoot(_ application: Application) throws {
        // Async инициализация в фоне (не блокирует startup)
        Task.detached(priority: .high) {
            do {
                _ = try await application.googleCloud.googleCloudStorage()
                application.logger.info("✅ Google Cloud Storage pre-initialized")
            } catch {
                application.logger.warning("⚠️ Google Cloud Storage pre-initialization failed: \(error)")
                // Не критично - создастся при первом использовании
            }
        }
    }
    
    public func shutdown(_ application: Application) {
        application.logger.info("Shutting down Google Cloud Storage")
        // HTTPClient закроется автоматически через storage cleanup
    }
}

