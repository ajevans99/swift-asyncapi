// Types shared at runtime between the builder and the generator.
import Foundation

public protocol ChannelParameterDecodable {
  init(from params: [String: String]) throws
}

public struct AnySendable: @unchecked Sendable {
  public let value: Any
  public init(_ value: Any) { self.value = value }
}

public struct ChannelContext: Sendable {
  public let handle: AnySendable

  public init(handle: Any) {
    self.handle = AnySendable(handle)
  }

  public func publish<M: Encodable>(_ message: M) async throws {
    // Stub implementation
  }
}

/// Runtime metadata for an AsyncAPI operation.
public struct OperationRuntime: Sendable {
  public let action: AsyncAPI.Action
  public let payloadType: Any.Type
  public let handler: @Sendable (Any, Any, ChannelContext) async throws -> Void

  public init(
    action: AsyncAPI.Action,
    payloadType: Any.Type,
    handler: @escaping @Sendable (Any, Any, ChannelContext) async throws -> Void
  ) {
    self.action = action
    self.payloadType = payloadType
    self.handler = handler
  }
}
