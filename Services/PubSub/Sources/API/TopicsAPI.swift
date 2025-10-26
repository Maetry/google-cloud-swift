import CloudCore
import AsyncHTTPClient
import Foundation

public protocol TopicsAPI: Sendable {
    /// Gets the configuration of a topic.
    ///
    /// - Parameters:
    ///   - topicId: Name of the topic
    ///   - topicProject: Name of the project that owns the topic. If not provided, the default project will be used.
    /// - Returns: If successful, the response body contains an instance of `Topic`.
    func get(topicId: String, topicProject: String?) async throws -> GoogleCloudPubSubTopic
    
    /// Lists matching topics.
    ///
    /// - Parameters:
    ///   - pageSize: Maximum number of topics to return.
    ///   - pageToken: The value returned by the last ListTopicsResponse; indicates that this is a continuation of a prior topics.list call, and that the system should return the next page of data
    ///   - topicProject: Name of the project that owns the topic. If not provided, the default project will be used.
    /// - Returns: Returns a list of topics and the `nextPageToken`
    func list(pageSize: Int?, pageToken: String?, topicProject: String?) async throws -> GooglePubSubListTopicResponse
    
    /// Adds one or more messages to the topic.
    ///
    /// - Parameters:
    ///   - topicId: Name of the topic
    ///   - topicProject: Name of the project that owns the topic. If not provided, the default project will be used.
    ///   - data: Data to be passed in the message
    ///   - attributes: Attributes for this message
    ///   - orderingKey: Identifies related messages for which publish order should be respected
    /// - Returns: Returns an array of `messageId`. `MessageId` is the server-assigned ID of each published message, in the same order as the messages in the request. IDs are guaranteed to be unique within the topic.
    func publish(topicId: String, topicProject: String?, data: String, attributes: [String: String]?, orderingKey: String?) async throws -> GoogleCloudPublishResponse
    
    /// Lists the names of the attached subscriptions on this topic.
    func getSubscriptionsList(topicId: String, topicProject: String?, pageSize: Int?, pageToken: String?) async throws -> GooglePubSubTopicSubscriptionListResponse
}

public extension TopicsAPI {
    func get(topicId: String, topicProject: String? = nil) async throws -> GoogleCloudPubSubTopic {
        try await get(topicId: topicId, topicProject: topicProject)
    }
    
    func list(pageSize: Int? = nil, pageToken: String? = nil, topicProject: String? = nil) async throws -> GooglePubSubListTopicResponse {
        try await list(pageSize: pageSize, pageToken: pageToken, topicProject: topicProject)
    }
    
    func publish(topicId: String, topicProject: String? = nil, data: String, attributes: [String: String]? = nil, orderingKey: String? = nil) async throws -> GoogleCloudPublishResponse {
        try await publish(topicId: topicId, topicProject: topicProject, data: data, attributes: attributes, orderingKey: orderingKey)
    }
    
    func getSubscriptionsList(topicId: String, topicProject: String? = nil, pageSize: Int? = nil, pageToken: String? = nil) async throws -> GooglePubSubTopicSubscriptionListResponse {
        try await getSubscriptionsList(topicId: topicId, topicProject: topicProject, pageSize: pageSize, pageToken: pageToken)
    }
}

public final class GoogleCloudPubSubTopicsAPI: TopicsAPI {
    let endpoint: String
    let request: GoogleCloudPubSubRequest
    let encoder = JSONEncoder()
    
    init(request: GoogleCloudPubSubRequest,
         endpoint: String) {
        self.request = request
        self.endpoint = endpoint
    }
    
    public func get(topicId: String, topicProject: String? = nil) async throws -> GoogleCloudPubSubTopic {
        try await request.send(method: .GET, path: "\(endpoint)/v1/projects/\(topicProject ?? request.project)/topics/\(topicId)")
    }
    
    public func list(pageSize: Int?, pageToken: String?, topicProject: String? = nil) async throws -> GooglePubSubListTopicResponse {
        var query = "pageSize=\(pageSize ?? 10)"
        if let pageToken = pageToken {
            query.append(contentsOf: "&pageToken=\(pageToken)")
        }
        
        return try await request.send(method: .GET,
                                      path: "\(endpoint)/v1/projects/\(topicProject ?? request.project)/topics",
                                      query: query)
    }
    
    public func publish(topicId: String, topicProject: String? = nil, data: String, attributes: [String: String]?, orderingKey: String?) async throws -> GoogleCloudPublishResponse {
        let message = GoogleCloudPubSubMessage(data: data, attributes: attributes, orderingKey: orderingKey)
        let publishRequest = GoogleCloudPublishRequest(messages: [message])
        let body = try HTTPClientRequest.Body.bytes(.init(data: encoder.encode(publishRequest)))
        let path = "\(endpoint)/v1/projects/\(topicProject ?? request.project)/topics/\(topicId):publish"
        
        return try await request.send(method: .POST,
                                      path: path,
                                      body: body)
    }
    
    public func getSubscriptionsList(topicId: String, topicProject: String? = nil, pageSize: Int?, pageToken: String?) async throws -> GooglePubSubTopicSubscriptionListResponse {
        var query = "pageSize=\(pageSize ?? 10)"
        if let pageToken = pageToken {
            query.append(contentsOf: "&pageToken=\(pageToken)")
        }
        
        return try await request.send(method: .GET,
                                      path: "\(endpoint)/v1/projects/\(topicProject ?? request.project)/topics/\(topicId)/subscriptions",
                                      query: query)
    }
}

