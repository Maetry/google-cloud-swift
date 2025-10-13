// Пример интеграции Google Cloud Storage с Vapor
// Для вашего случая: загрузка аватарок на Cloud Run

import Vapor
import CloudStorage

// ============================================================================
// configure.swift
// ============================================================================

public func configure(_ app: Application) throws {
    
    // 1. Базовые настройки Vapor
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = Int(Environment.get("PORT") ?? "8080")!
    
    // 2. Database (ваша БД)
    app.databases.use(.postgres(
        hostname: Environment.get("DB_HOST") ?? "localhost",
        port: 5432,
        username: Environment.get("DB_USER") ?? "vapor",
        password: Environment.get("DB_PASSWORD") ?? "password",
        database: Environment.get("DB_NAME") ?? "vapor"
    ), as: .psql)
    
    // 3. Google Cloud Storage - ЛЕНИВАЯ ИНИЦИАЛИЗАЦИЯ
    if app.environment == .production {
        // Cloud Run: metadata server (автоматически)
        app.googleCloud.credentials = GoogleCloudCredentialsConfiguration()
        app.logger.info("🔐 Google Cloud: using Cloud Run metadata server")
    } else {
        // Локальная разработка
        if let credPath = Environment.get("GOOGLE_APPLICATION_CREDENTIALS") {
            app.googleCloud.credentials = GoogleCloudCredentialsConfiguration(
                credentialsFile: credPath
            )
            app.logger.info("🔐 Google Cloud: using credentials file: \(credPath)")
        } else {
            // gcloud ADC
            app.googleCloud.credentials = GoogleCloudCredentialsConfiguration()
            app.logger.info("🔐 Google Cloud: using gcloud ADC")
        }
    }
    
    // Конфигурация Storage
    app.googleCloud.storage.configuration = GoogleCloudStorageConfiguration(
        scope: [.fullControl],  // Нужен для ACL операций
        serviceAccount: "default"
    )
    
    // 4. Опционально: фоновый прогрев (не обязательно)
    // app.lifecycle.use(StorageWarmup())
    
    // 5. Routes
    try routes(app)
    
    app.logger.info("✅ Application configured successfully")
}

// ============================================================================
// routes.swift
// ============================================================================

func routes(_ app: Application) throws {
    
    // Health check для Cloud Run
    app.get("health") { req -> HTTPStatus in
        return .ok
    }
    
    // Test endpoint для проверки Storage
    app.get("test-storage") { req async throws -> String in
        do {
            let buckets = try await req.gcs.buckets.list(queryParameters: ["maxResults": "1"])
            let count = buckets.items?.count ?? 0
            return "✅ Storage auth works! Found \(count) buckets"
        } catch let error as CloudStorageAPIError {
            return "❌ Storage error: \(error.error.message) (code: \(error.error.code))"
        } catch {
            return "❌ Error: \(error.localizedDescription)"
        }
    }
    
    // Загрузка аватарки
    app.on(.POST, "users", ":id", "avatar", body: .collect(maxSize: "5mb")) { 
        req async throws -> AvatarResponse in
        
        let userId = try req.parameters.require("id", as: UUID.self)
        
        // Логирование
        req.logger.info("📸 Avatar upload started", metadata: [
            "user_id": .string(userId.uuidString)
        ])
        
        let startTime = Date()
        
        // Получаем данные файла
        guard let data = req.body.data, !data.isEmpty else {
            throw Abort(.badRequest, reason: "Файл пустой или отсутствует")
        }
        
        // Проверка размера (дополнительно)
        guard data.count <= 5 * 1024 * 1024 else {
            throw Abort(.payloadTooLarge, reason: "Максимальный размер 5 MB")
        }
        
        // Проверка типа файла (базовая)
        guard isValidImage(data) else {
            throw Abort(.badRequest, reason: "Файл должен быть изображением (JPEG/PNG)")
        }
        
        // Storage client (ленивая инициализация)
        let storage = req.gcs
        
        // Генерация имени файла
        let filename = "\(userId)/avatar.jpg"
        let bucketName = Environment.get("AVATAR_BUCKET") ?? "my-app-avatars"
        
        do {
            // 1. Загрузка в Storage
            req.logger.debug("⬆️  Uploading to Storage...")
            let object = try await storage.object.createSimpleUpload(
                bucket: bucketName,
                data: data,
                name: filename,
                contentType: "image/jpeg"
            )
            
            // 2. Установка публичного доступа
            req.logger.debug("🔓 Setting public ACL...")
            try await storage.objectAccessControl.insert(
                bucket: bucketName,
                object: filename,
                entity: "allUsers",
                role: "READER"
            )
            
            // 3. Формирование публичной ссылки
            let publicURL = "https://storage.googleapis.com/\(bucketName)/\(filename)"
            
            // 4. Сохранение в БД
            req.logger.debug("💾 Updating database...")
            guard var user = try await User.find(userId, on: req.db) else {
                throw Abort(.notFound, reason: "Пользователь не найден")
            }
            
            // Удаляем старую аватарку (опционально)
            if let oldURL = user.avatarURL {
                Task {
                    try? await deleteOldAvatar(url: oldURL, storage: storage, bucket: bucketName)
                }
            }
            
            user.avatarURL = publicURL
            try await user.save(on: req.db)
            
            // Логирование успеха
            let duration = Date().timeIntervalSince(startTime)
            req.logger.info("✅ Avatar uploaded successfully", metadata: [
                "user_id": .string(userId.uuidString),
                "duration": .string("\(String(format: "%.2f", duration))s"),
                "size": .string("\(data.count) bytes"),
                "url": .string(publicURL)
            ])
            
            return AvatarResponse(
                url: publicURL,
                uploadedAt: Date(),
                size: data.count
            )
            
        } catch let error as CloudStorageAPIError {
            req.logger.error("❌ Storage API error", metadata: [
                "code": .string("\(error.error.code)"),
                "message": .string(error.error.message)
            ])
            
            if error.error.code == 403 {
                throw Abort(.forbidden, reason: "Недостаточно прав для загрузки. Проверьте IAM роли Service Account.")
            } else if error.error.code == 404 {
                throw Abort(.notFound, reason: "Bucket '\(bucketName)' не найден")
            } else {
                throw Abort(.internalServerError, reason: "Ошибка Storage: \(error.error.message)")
            }
        }
    }
    
    // Удаление аватарки
    app.delete("users", ":id", "avatar") { req async throws -> HTTPStatus in
        let userId = try req.parameters.require("id", as: UUID.self)
        
        guard let user = try await User.find(userId, on: req.db),
              let avatarURL = user.avatarURL else {
            throw Abort(.notFound)
        }
        
        let storage = req.gcs
        let bucketName = Environment.get("AVATAR_BUCKET") ?? "my-app-avatars"
        
        // Извлекаем filename из URL
        if let filename = extractFilename(from: avatarURL) {
            try await storage.object.delete(bucket: bucketName, object: filename)
        }
        
        // Удаляем из БД
        var updatedUser = user
        updatedUser.avatarURL = nil
        try await updatedUser.save(on: req.db)
        
        req.logger.info("🗑️  Avatar deleted", metadata: ["user_id": .string(userId.uuidString)])
        
        return .noContent
    }
}

// ============================================================================
// Helper Functions
// ============================================================================

func isValidImage(_ data: Data) -> Bool {
    guard data.count > 4 else { return false }
    
    let bytes = [UInt8](data.prefix(4))
    
    // JPEG: FF D8 FF
    if bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF {
        return true
    }
    
    // PNG: 89 50 4E 47
    if bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47 {
        return true
    }
    
    return false
}

func extractFilename(from url: String) -> String? {
    // https://storage.googleapis.com/bucket-name/user-id/avatar.jpg
    // -> user-id/avatar.jpg
    let components = url.components(separatedBy: "/")
    guard components.count >= 5 else { return nil }
    return components.dropFirst(4).joined(separator: "/")
}

func deleteOldAvatar(url: String, storage: GoogleCloudStorageClient, bucket: String) async throws {
    if let filename = extractFilename(from: url) {
        try await storage.object.delete(bucket: bucket, object: filename)
    }
}

// ============================================================================
// Models
// ============================================================================

struct AvatarResponse: Content {
    let url: String
    let uploadedAt: Date
    let size: Int
}

// Пример User модели
final class User: Model {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "avatar_url")
    var avatarURL: String?
    
    init() { }
}

// ============================================================================
// Опционально: Фоновый прогрев Storage (если нужно)
// ============================================================================

struct StorageWarmup: LifecycleHandler {
    func didBoot(_ application: Application) throws {
        Task.detached(priority: .background) {
            try? await Task.sleep(for: .seconds(2))
            
            do {
                let _ = application.googleCloud.storage.client
                application.logger.info("🔥 Storage warmed up in background")
            } catch {
                application.logger.debug("Storage warmup skipped: \(error)")
            }
        }
    }
    
    func shutdown(_ application: Application) {
        application.logger.info("Shutting down Storage")
    }
}

// ============================================================================
// Environment Variables для Cloud Run
// ============================================================================

/*
Установите в Cloud Run:

gcloud run deploy my-vapor-app \
  --image gcr.io/PROJECT/vapor-app:latest \
  --service-account vapor-storage@PROJECT.iam.gserviceaccount.com \
  --set-env-vars AVATAR_BUCKET=my-app-avatars \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated

Опциональные переменные:
- GOOGLE_PROJECT_ID=my-project-123
- LOG_LEVEL=debug (для детального логирования)
*/

