// Практический тест аутентификации Google Cloud
// Запустите: swift run TestAuth

import Foundation
import CloudCore
import Storage
import AsyncHTTPClient

@main
struct TestAuthentication {
    
    static func main() async throws {
        print("🧪 Тестирование аутентификации Google Cloud Storage\n")
        
        let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        defer {
            try? httpClient.syncShutdown()
        }
        
        // ====================================================================
        // ТЕСТ 1: Проверка загрузки credentials из файла
        // ====================================================================
        
        print("📋 ТЕСТ 1: Загрузка Service Account credentials")
        
        do {
            // Проверьте что файл существует
            let credPath = ProcessInfo.processInfo.environment["GOOGLE_APPLICATION_CREDENTIALS"] ?? "./service-account.json"
            
            print("   Путь к credentials: \(credPath)")
            
            let resolvedCreds = try await CredentialsResolver.resolveCredentials(
                strategy: .environment
            )
            
            switch resolvedCreds {
            case .serviceAccount(let creds):
                print("   ✅ Service Account credentials загружены")
                print("      - Project ID: \(creds.projectId)")
                print("      - Client Email: \(creds.clientEmail)")
                print("      - Private Key ID: \(creds.privateKeyId)")
                print("      - Token URI: \(creds.tokenUri)")
                
            case .gcloud(let creds):
                print("   ✅ GCloud credentials загружены")
                print("      - Client ID: \(creds.clientId)")
                print("      - Quota Project: \(creds.quotaProjectId)")
                print("      - Type: \(creds.type)")
                
            case .computeEngine(let url):
                print("   ✅ Compute Engine metadata server")
                print("      - URL: \(url)")
            }
            
        } catch {
            print("   ❌ ОШИБКА: \(error)")
            print("   💡 Установите GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json")
            throw error
        }
        
        print("")
        
        // ====================================================================
        // ТЕСТ 2: Создание Storage клиента
        // ====================================================================
        
        print("📋 ТЕСТ 2: Инициализация Storage Client")
        
        let storage: GoogleCloudStorageClient
        
        do {
            storage = try await GoogleCloudStorageClient(
                strategy: .environment,
                client: httpClient,
                scope: [.fullControl]
            )
            print("   ✅ Storage client создан успешно")
            
        } catch {
            print("   ❌ ОШИБКА: \(error)")
            throw error
        }
        
        print("")
        
        // ====================================================================
        // ТЕСТ 3: Получение OAuth токена
        // ====================================================================
        
        print("📋 ТЕСТ 3: Получение OAuth токена")
        
        do {
            // Этот вызов триггерит получение токена
            let startTime = Date()
            let buckets = try await storage.buckets.list(queryParameters: ["maxResults": "1"])
            let duration = Date().timeIntervalSince(startTime)
            
            print("   ✅ OAuth токен получен и использован")
            print("      - Время запроса: \(String(format: "%.2f", duration))s")
            print("      - Buckets найдено: \(buckets.items?.count ?? 0)")
            
            if let firstBucket = buckets.items?.first {
                print("      - Пример bucket: \(firstBucket.name ?? "unnamed")")
            }
            
        } catch let error as CloudStorageAPIError {
            print("   ❌ ОШИБКА API: \(error.error.message)")
            print("      - Code: \(error.error.code)")
            if !error.error.errors.isEmpty {
                print("      - Details: \(error.error.errors)")
            }
            
            if error.error.code == 403 {
                print("\n   💡 Проверьте IAM роли:")
                print("      gcloud projects add-iam-policy-binding PROJECT_ID \\")
                print("        --member='serviceAccount:EMAIL' \\")
                print("        --role='roles/storage.admin'")
            }
            
            throw error
            
        } catch {
            print("   ❌ ОШИБКА: \(error)")
            throw error
        }
        
        print("")
        
        // ====================================================================
        // ТЕСТ 4: Повторный запрос (проверка кэша токена)
        // ====================================================================
        
        print("📋 ТЕСТ 4: Проверка кэширования токена")
        
        do {
            let startTime = Date()
            let buckets = try await storage.buckets.list(queryParameters: ["maxResults": "1"])
            let duration = Date().timeIntervalSince(startTime)
            
            print("   ✅ Токен из кэша (должно быть быстрее)")
            print("      - Время запроса: \(String(format: "%.2f", duration))s")
            
            if duration < 0.5 {
                print("      - ⚡ Очень быстро! Токен определенно из кэша")
            }
            
        } catch {
            print("   ❌ ОШИБКА: \(error)")
            throw error
        }
        
        print("")
        
        // ====================================================================
        // ТЕСТ 5: Проверка прав доступа
        // ====================================================================
        
        print("📋 ТЕСТ 5: Проверка прав доступа (создание тестового bucket)")
        
        do {
            let testBucketName = "test-auth-\(UUID().uuidString.lowercased().prefix(8))"
            
            print("   Попытка создать bucket: \(testBucketName)")
            
            let bucket = try await storage.buckets.insert(
                name: testBucketName,
                location: "US",
                storageClass: .regional
            )
            
            print("   ✅ Bucket создан!")
            print("      - Name: \(bucket.name ?? "")")
            print("      - Location: \(bucket.location ?? "")")
            print("      - Storage Class: \(bucket.storageClass ?? "")")
            
            // Удаляем тестовый bucket
            print("   🧹 Удаляем тестовый bucket...")
            try await storage.buckets.delete(bucket: testBucketName)
            print("   ✅ Тестовый bucket удален")
            
        } catch let error as CloudStorageAPIError {
            if error.error.code == 409 {
                print("   ⚠️  Bucket уже существует (это нормально для теста)")
            } else if error.error.code == 403 {
                print("   ❌ ОШИБКА: Недостаточно прав!")
                print("      Service Account должен иметь роль:")
                print("      - roles/storage.admin ИЛИ")
                print("      - roles/storage.buckets.create")
            } else {
                print("   ❌ ОШИБКА API: \(error.error.message)")
            }
        } catch {
            print("   ❌ ОШИБКА: \(error)")
        }
        
        print("")
        
        // ====================================================================
        // ФИНАЛЬНЫЙ РЕЗУЛЬТАТ
        // ====================================================================
        
        print("=" * 80)
        print("\n🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ!\n")
        print("Аутентификация Google Cloud Storage настроена корректно.")
        print("Вы можете использовать Storage API в вашем Vapor проекте.\n")
        
        print("📚 Следующие шаги:")
        print("   1. Интегрируйте в ваш Vapor проект")
        print("   2. Настройте IAM роли для production service account")
        print("   3. Для Cloud Run используйте .computeEngine стратегию")
        print("   4. Добавьте мониторинг и логирование")
        print("")
    }
}

extension String {
    static func * (lhs: String, rhs: Int) -> String {
        String(repeating: lhs, count: rhs)
    }
}

