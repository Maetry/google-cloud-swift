//
//  FirebaseMessagingTests.swift
//  GoogleCloudKit
//
//  Created by Assistant on 2025-01-27.
//

import XCTest
@testable import FirebaseMessaging

final class FirebaseMessagingTests: XCTestCase {
    
    func testFirebaseMessageCreation() throws {
        let message = FirebaseMessage(
            token: "test_token",
            data: ["key": "value"],
            notification: FirebaseNotification(
                title: "Test Title",
                body: "Test Body"
            )
        )
        
        XCTAssertEqual(message.token, "test_token")
        XCTAssertEqual(message.notification?.title, "Test Title")
        XCTAssertEqual(message.notification?.body, "Test Body")
        XCTAssertEqual(message.data?["key"], "value")
    }
    
    func testFirebaseNotificationCreation() throws {
        let notification = FirebaseNotification(
            title: "Test Title",
            body: "Test Body",
            image: "https://example.com/image.png"
        )
        
        XCTAssertEqual(notification.title, "Test Title")
        XCTAssertEqual(notification.body, "Test Body")
        XCTAssertEqual(notification.image, "https://example.com/image.png")
    }
    
    func testFirebaseAndroidConfigCreation() throws {
        let androidConfig = FirebaseAndroidConfig(
            priority: "high",
            ttl: "3600s",
            notification: FirebaseAndroidNotification(
                title: "Android Title",
                body: "Android Body",
                icon: "ic_notification",
                color: "#FF0000"
            )
        )
        
        XCTAssertEqual(androidConfig.priority, "high")
        XCTAssertEqual(androidConfig.ttl, "3600s")
        XCTAssertEqual(androidConfig.notification?.title, "Android Title")
        XCTAssertEqual(androidConfig.notification?.body, "Android Body")
        XCTAssertEqual(androidConfig.notification?.icon, "ic_notification")
        XCTAssertEqual(androidConfig.notification?.color, "#FF0000")
    }
    
    func testFirebaseAPNSConfigCreation() throws {
        let apnsConfig = FirebaseAPNSConfig(
            headers: ["apns-priority": "10"],
            payload: FirebaseAPNSPayload(
                aps: FirebaseAPS(
                    alert: FirebaseAPSAlert(
                        title: "iOS Title",
                        subtitle: "iOS Subtitle",
                        body: "iOS Body"
                    ),
                    sound: "default",
                    badge: 1
                )
            )
        )
        
        XCTAssertEqual(apnsConfig.headers?["apns-priority"], "10")
        XCTAssertEqual(apnsConfig.payload?.aps?.alert?.title, "iOS Title")
        XCTAssertEqual(apnsConfig.payload?.aps?.alert?.subtitle, "iOS Subtitle")
        XCTAssertEqual(apnsConfig.payload?.aps?.alert?.body, "iOS Body")
        XCTAssertEqual(apnsConfig.payload?.aps?.sound, "default")
        XCTAssertEqual(apnsConfig.payload?.aps?.badge, 1)
    }
    
    func testFirebaseWebpushConfigCreation() throws {
        let webpushConfig = FirebaseWebpushConfig(
            headers: ["TTL": "300"],
            notification: FirebaseWebpushNotification(
                title: "Web Title",
                body: "Web Body",
                icon: "/icon.png",
                url: "https://example.com"
            )
        )
        
        XCTAssertEqual(webpushConfig.headers?["TTL"], "300")
        XCTAssertEqual(webpushConfig.notification?.title, "Web Title")
        XCTAssertEqual(webpushConfig.notification?.body, "Web Body")
        XCTAssertEqual(webpushConfig.notification?.icon, "/icon.png")
        XCTAssertEqual(webpushConfig.notification?.url, "https://example.com")
    }
    
    func testFirebaseResponseCreation() throws {
        let response = FirebaseResponse(
            name: "projects/test-project/messages/123",
            results: [
                FirebaseSendResult(
                    messageId: "123",
                    canonicalRegistrationToken: nil,
                    errorCode: nil,
                    errorDescription: nil
                )
            ],
            successCount: 1,
            failureCount: 0
        )
        
        XCTAssertEqual(response.name, "projects/test-project/messages/123")
        XCTAssertEqual(response.results?.count, 1)
        XCTAssertEqual(response.results?.first?.messageId, "123")
        XCTAssertEqual(response.successCount, 1)
        XCTAssertEqual(response.failureCount, 0)
    }
    
    func testFirebaseErrorCreation() throws {
        let error = FirebaseError(
            code: 400,
            message: "Invalid token",
            status: "INVALID_ARGUMENT",
            details: [
                FirebaseErrorDetail(
                    type: "type.googleapis.com/google.rpc.BadRequest",
                    detail: "Token is invalid"
                )
            ]
        )
        
        XCTAssertEqual(error.code, 400)
        XCTAssertEqual(error.message, "Invalid token")
        XCTAssertEqual(error.status, "INVALID_ARGUMENT")
        XCTAssertEqual(error.details?.count, 1)
        XCTAssertEqual(error.details?.first?.type, "type.googleapis.com/google.rpc.BadRequest")
        XCTAssertEqual(error.details?.first?.detail, "Token is invalid")
    }
    
    // MARK: - Convenience Methods Tests
    
    func testSimpleMessageCreation() throws {
        let message = FirebaseMessage.simple("Test Title", "Test Body", to: "test_token")
        
        XCTAssertEqual(message.token, "test_token")
        XCTAssertEqual(message.notification?.title, "Test Title")
        XCTAssertEqual(message.notification?.body, "Test Body")
        XCTAssertNil(message.data)
    }
    
    func testDataMessageCreation() throws {
        let data = ["key": "value", "type": "test"]
        let message = FirebaseMessage.data("Test Title", "Test Body", to: "test_token", data: data)
        
        XCTAssertEqual(message.token, "test_token")
        XCTAssertEqual(message.notification?.title, "Test Title")
        XCTAssertEqual(message.notification?.body, "Test Body")
        XCTAssertEqual(message.data?["key"], "value")
        XCTAssertEqual(message.data?["type"], "test")
    }
    
    func testMulticastMessageCreation() throws {
        let tokens = ["token1", "token2", "token3"]
        let message = FirebaseMessage.multicast("Multicast Title", "Multicast Body", to: tokens)
        
        XCTAssertEqual(message.tokens, tokens)
        XCTAssertEqual(message.notification?.title, "Multicast Title")
        XCTAssertEqual(message.notification?.body, "Multicast Body")
        XCTAssertNil(message.token)
    }
    
    func testTopicMessageCreation() throws {
        let message = FirebaseMessage.topic("News Title", "News Body", topic: "news")
        
        XCTAssertEqual(message.topic, "news")
        XCTAssertEqual(message.notification?.title, "News Title")
        XCTAssertEqual(message.notification?.body, "News Body")
        XCTAssertNil(message.token)
    }
    
    func testConditionalMessageCreation() throws {
        let message = FirebaseMessage.conditional("Conditional Title", "Conditional Body", condition: "'news' in topics")
        
        XCTAssertEqual(message.condition, "'news' in topics")
        XCTAssertEqual(message.notification?.title, "Conditional Title")
        XCTAssertEqual(message.notification?.body, "Conditional Body")
        XCTAssertNil(message.token)
    }
    
    func testBadgeMessageCreation() throws {
        let message = FirebaseMessage.badge("Badge Title", "Badge Body", to: "test_token", count: 5, category: "messages")
        
        XCTAssertEqual(message.token, "test_token")
        XCTAssertEqual(message.notification?.title, "Badge Title")
        XCTAssertEqual(message.notification?.body, "Badge Body")
        XCTAssertEqual(message.apns?.payload?.aps?.badge, 5)
        XCTAssertEqual(message.apns?.payload?.aps?.category, "messages")
        XCTAssertEqual(message.webpush?.notification?.badge, "5")
    }
    
    func testAndroidMessageCreation() throws {
        let message = FirebaseMessage.android("Android Title", "Android Body", to: "android_token", 
                                            channel: "news_channel", color: "#FF0000")
        
        XCTAssertEqual(message.token, "android_token")
        XCTAssertEqual(message.notification?.title, "Android Title")
        XCTAssertEqual(message.notification?.body, "Android Body")
        XCTAssertEqual(message.android?.priority, "high")
        XCTAssertEqual(message.android?.notification?.channelId, "news_channel")
        XCTAssertEqual(message.android?.notification?.color, "#FF0000")
    }
    
    func testIOSMessageCreation() throws {
        let message = FirebaseMessage.ios("iOS Title", "iOS Body", to: "ios_token", 
                                        badge: 3, category: "NEWS_CATEGORY")
        
        XCTAssertEqual(message.token, "ios_token")
        XCTAssertEqual(message.notification?.title, "iOS Title")
        XCTAssertEqual(message.notification?.body, "iOS Body")
        XCTAssertEqual(message.apns?.payload?.aps?.badge, 3)
        XCTAssertEqual(message.apns?.payload?.aps?.category, "NEWS_CATEGORY")
    }
    
    func testWebMessageCreation() throws {
        let message = FirebaseMessage.web("Web Title", "Web Body", to: "web_token", 
                                        icon: "/icon.png", url: "https://example.com")
        
        XCTAssertEqual(message.token, "web_token")
        XCTAssertEqual(message.notification?.title, "Web Title")
        XCTAssertEqual(message.notification?.body, "Web Body")
        XCTAssertEqual(message.webpush?.notification?.icon, "/icon.png")
        XCTAssertEqual(message.webpush?.notification?.url, "https://example.com")
    }
    
    func testUniversalMessageCreation() throws {
        let message = FirebaseMessage.universal("Cross Title", "Cross Body", to: "cross_token",
                                              badge: 2, category: "general", data: ["type": "notification"])
        
        XCTAssertEqual(message.token, "cross_token")
        XCTAssertEqual(message.notification?.title, "Cross Title")
        XCTAssertEqual(message.notification?.body, "Cross Body")
        XCTAssertEqual(message.data?["type"], "notification")
        XCTAssertEqual(message.apns?.payload?.aps?.badge, 2)
        XCTAssertEqual(message.apns?.payload?.aps?.category, "general")
        XCTAssertEqual(message.webpush?.notification?.badge, "2")
    }
}
