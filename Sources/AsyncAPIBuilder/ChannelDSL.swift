import AsyncAPIGenerator
import JSONSchema

// Builder for operations defined within a Channel
public final class OperationBuilder {
    let action: AsyncAPI.Action
    let payloadType: Any.Type
    let handler: @Sendable (Any, Any, ChannelContext) async throws -> Void
    var summary: String?
    var description: String?
    var tags: [AsyncAPI.Tag]?
    var externalDocs: AsyncAPI.ExternalDoc?
    var bindings: JSONValue?

    init(action: AsyncAPI.Action, payloadType: Any.Type, handler: @escaping @Sendable (Any, Any, ChannelContext) async throws -> Void) {
        self.action = action
        self.payloadType = payloadType
        self.handler = handler
    }

    @discardableResult
    public func summary(_ value: String) -> Self { self.summary = value; return self }

    @discardableResult
    public func description(_ value: String) -> Self { self.description = value; return self }

    @discardableResult
    public func tags(_ value: [AsyncAPI.Tag]) -> Self { self.tags = value; return self }

    @discardableResult
    public func externalDocs(_ value: AsyncAPI.ExternalDoc) -> Self { self.externalDocs = value; return self }

    @discardableResult
    public func bindings(_ value: JSONValue) -> Self { self.bindings = value; return self }
}

// Builder used inside Channel DSL closures
public struct ChannelBuilder {
    let address: String
    var parameters: [String: JSONValue] = [:]
    var operations: [OperationBuilder] = []
    var summary: String?
    var description: String?
    var tags: [AsyncAPI.Tag]?
    var externalDocs: AsyncAPI.ExternalDoc?
    var bindings: JSONValue?

    public init(address: String) {
        self.address = address
    }

    @discardableResult
    public mutating func parameter(_ name: String, _ schema: JSONValue) -> Self {
        parameters[name] = schema
        return self
    }

    @discardableResult
    public mutating func subscribe<M: Decodable, P: ChannelParameterDecodable>(
        _ payloadType: M.Type,
        handler: @Sendable @escaping (P, M, ChannelContext) async throws -> Void
    ) -> OperationBuilder {
        let generic: @Sendable (Any, Any, ChannelContext) async throws -> Void = { p, m, ctx in
            guard let p = p as? P, let m = m as? M else { return }
            try await handler(p, m, ctx)
        }
        let builder = OperationBuilder(action: .receive, payloadType: payloadType, handler: generic)
        operations.append(builder)
        return builder
    }

    @discardableResult
    public mutating func publish<M: Encodable>(
        _ payloadType: M.Type,
        handler: @Sendable @escaping (M, ChannelContext) async throws -> Void = { _, _ in }
    ) -> OperationBuilder {
        let generic: @Sendable (Any, Any, ChannelContext) async throws -> Void = { msg, _, ctx in
            if let msg = msg as? M {
                try await handler(msg, ctx)
            }
        }
        let builder = OperationBuilder(action: .send, payloadType: payloadType, handler: generic)
        operations.append(builder)
        return builder
    }

    @discardableResult
    public mutating func summary(_ value: String) -> Self { self.summary = value; return self }

    @discardableResult
    public mutating func description(_ value: String) -> Self { self.description = value; return self }

    @discardableResult
    public mutating func tags(_ value: [AsyncAPI.Tag]) -> Self { self.tags = value; return self }

    @discardableResult
    public mutating func externalDocs(_ value: AsyncAPI.ExternalDoc) -> Self { self.externalDocs = value; return self }

    @discardableResult
    public mutating func bindings(_ value: JSONValue) -> Self { self.bindings = value; return self }

    public func finish() -> AsyncAPI.Channel {
        AsyncAPI.Channel(
            address: address,
            summary: summary,
            description: description,
            tags: tags,
            externalDocs: externalDocs,
            bindings: bindings
        )
    }

    func buildOperations(channelKey: String) -> [String: AsyncAPI.Operation] {
        var result: [String: AsyncAPI.Operation] = [:]
        for (idx, op) in operations.enumerated() {
            let key = "\(channelKey)-\(idx)"
            let operation = AsyncAPI.Operation(
                action: op.action,
                channel: .reference("#/channels/\(channelKey)"),
                messages: nil,
                reply: nil,
                traits: nil,
                title: nil,
                summary: op.summary,
                description: op.description,
                security: nil,
                tags: op.tags,
                externalDocs: op.externalDocs,
                bindings: op.bindings
            )
            result[key] = operation
            let runtime = OperationRuntime(
                action: op.action,
                payloadType: op.payloadType,
                handler: op.handler
            )
            Task {
                await RuntimeRegistry.shared.registerOperation(key, runtime: runtime)
            }
        }
        return result
    }
}
