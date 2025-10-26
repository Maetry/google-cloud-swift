//
//  GoogleCloudPlatform+FirebaseMessaging.swift
//  GoogleCloud
//
//  Improved integration following Vapor 4.x best practices
//

import Vapor
import CloudCore
import FirebaseMessaging
import AsyncHTTPClient
import VaporGoogleCloudCore

// MARK: - Application.GoogleCloudPlatform Extension

extension Application.GoogleCloudPlatform {
    
    public struct FirebaseMessagingClientKey: StorageKey, LockKey {
        public typealias Value = GoogleCloudFirebaseMessagingClient
    }
    
    private struct FirebaseMessagingConfigurationKey: StorageKey {
        typealias Value = GoogleCloudFirebaseMessagingConfiguration
    }
    
    private struct FirebaseMessagingHTTPClientKey: StorageKey, LockKey {
        typealias Value = HTTPClient
    }
    
    /// Configuration for Firebase Messaging API
    public var firebaseMessagingConfiguration: GoogleCloudFirebaseMessagingConfiguration {
        get {
            guard let config = application.storage[FirebaseMessagingConfigurationKey.self] else {
                fatalError("Firebase Messaging configuration has not been set. Use app.googleCloud.firebaseMessagingConfiguration = ...")
            }
            return config
        }
        nonmutating set {
            guard application.storage[FirebaseMessagingConfigurationKey.self] == nil else {
                fatalError("Attempting to override Firebase Messaging configuration after being set is not allowed.")
            }
            application.storage[FirebaseMessagingConfigurationKey.self] = newValue
        }
    }
    
    /// HTTP Client для Firebase Messaging (переиспользуемый)
    public var firebaseMessagingHTTPClient: HTTPClient {
        if let existing = application.storage[FirebaseMessagingHTTPClientKey.self] {
            return existing
        }
        
        let lock = application.locks.lock(for: FirebaseMessagingHTTPClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        // Double-check после получения lock
        if let existing = application.storage[FirebaseMessagingHTTPClientKey.self] {
            return existing
        }
        
        let new = HTTPClient(
            eventLoopGroupProvider: .shared(application.eventLoopGroup),
            configuration: HTTPClient.Configuration(ignoreUncleanSSLShutdown: true)
        )
        
        application.storage.set(FirebaseMessagingHTTPClientKey.self, to: new) {
            try? $0.syncShutdown()
        }
        
        return new
    }
    
    /// Получить или создать Firebase Messaging клиент (async, thread-safe)
    public func googleCloudFirebaseMessaging() async throws -> GoogleCloudFirebaseMessagingClient {
        // Проверка кэша
        if let existing = application.storage[FirebaseMessagingClientKey.self] {
            return existing
        }
        
        // Thread-safe инициализация
        let lock = application.locks.lock(for: FirebaseMessagingClientKey.self)
        lock.lock()
        defer { lock.unlock() }
        
        // Double-check после получения lock
        if let existing = application.storage[FirebaseMessagingClientKey.self] {
            return existing
        }
        
        // Создаем клиент (async, без блокировки!)
        let client = try await GoogleCloudFirebaseMessagingClient(
            strategy: credentials.strategy,
            client: firebaseMessagingHTTPClient,
            base: firebaseMessagingConfiguration.base,
            scope: firebaseMessagingConfiguration.concreteScope
        )
        
        application.storage[FirebaseMessagingClientKey.self] = client
        application.logger.info("✅ Google Cloud Firebase Messaging client initialized")
        
        return client
    }
}

// MARK: - Request Extension

extension Request {
    
    /// Получить Google Cloud Firebase Messaging клиент (async, thread-safe, lazy initialization)
    ///
    /// Использование:
    /// ```swift
    /// app.post("send-notification") { req async throws in
    ///     let messaging = try await req.googleCloudFirebaseMessaging()
    ///     let response = try await messaging.send(message)
    /// }
    /// ```
    ///
    /// - Returns: Инициализированный GoogleCloudFirebaseMessagingClient
    /// - Throws: Ошибки при инициализации или отсутствии конфигурации
    public func googleCloudFirebaseMessaging() async throws -> GoogleCloudFirebaseMessagingClient {
        try await application.googleCloud.googleCloudFirebaseMessaging()
    }
}

// MARK: - Lifecycle Handler

/// Lifecycle handler для предварительной инициализации Google Cloud Firebase Messaging
///
/// Использование в configure.swift:
/// ```
/// app.lifecycle.use(GoogleCloudFirebaseMessagingLifecycle())
/// ```
public struct GoogleCloudFirebaseMessagingLifecycle: LifecycleHandler {
    public init() {}
    
    public func didBoot(_ application: Application) throws {
        // Async инициализация в фоне (не блокирует startup)
        Task.detached(priority: .high) {
            do {
                _ = try await application.googleCloud.googleCloudFirebaseMessaging()
                application.logger.info("✅ Google Cloud Firebase Messaging pre-initialized")
            } catch {
                application.logger.warning("⚠️ Google Cloud Firebase Messaging pre-initialization failed: \(error)")
                // Не критично - создастся при первом использовании
            }
        }
    }
    
    public func shutdown(_ application: Application) {
        application.logger.info("Shutting down Google Cloud Firebase Messaging")
    }
}
