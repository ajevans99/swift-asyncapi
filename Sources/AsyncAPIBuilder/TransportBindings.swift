import AsyncAPIGenerator

public protocol TransportBinder: Sendable {
  func bind(
    server: AsyncAPI.Server,
    channel: AsyncAPI.Channel,
    operation: AsyncAPI.Operation,
    using binderContext: BinderContext
  ) throws
}

public struct BinderContext {
  public init() {}
}

public actor BinderRegistry {
  public static let shared = BinderRegistry()
  private var registry: [String: TransportBinder] = [:]
  private init() {}

  public func register(_ proto: String, _ binder: TransportBinder) {
    registry[proto] = binder
  }

  public func binder(for proto: String) -> TransportBinder? {
    registry[proto]
  }

  public func registerDefaults() {
    registry["ws"] = WebSocketBinder()
    registry["http"] = HTTPBinder()
    registry["kafka"] = KafkaBinder()
  }
}

public struct WebSocketBinder: TransportBinder {
  public init() {}
  public func bind(
    server: AsyncAPI.Server,
    channel: AsyncAPI.Channel,
    operation: AsyncAPI.Operation,
    using binderContext: BinderContext
  ) throws {
    // Stub implementation
  }
}

public struct HTTPBinder: TransportBinder {
  public init() {}
  public func bind(
    server: AsyncAPI.Server,
    channel: AsyncAPI.Channel,
    operation: AsyncAPI.Operation,
    using binderContext: BinderContext
  ) throws {
    // Stub implementation
  }
}

public struct KafkaBinder: TransportBinder {
  public init() {}
  public func bind(
    server: AsyncAPI.Server,
    channel: AsyncAPI.Channel,
    operation: AsyncAPI.Operation,
    using binderContext: BinderContext
  ) throws {
    // Stub implementation
  }
}

public func expandOperations(
  in channel: AsyncAPI.Channel,
  document: AsyncAPI
) -> [AsyncAPI.Operation] {
  guard let operations = document.operations else { return [] }
  var result: [AsyncAPI.Operation] = []
  for key in operations.keys.sorted() {
    let op = operations[key]!
    switch op.channel {
    case .reference(let ref):
      if ref == "#/channels/\(channel.address ?? "")" { result.append(op) }
    case .value(let value):
      if value.address == channel.address { result.append(op) }
    }
  }
  return result
}

extension AsyncAPI {
  public func bind(using context: BinderContext) async throws {
    await BinderRegistry.shared.registerDefaults()
    for (_, server) in servers ?? [:] {
      let proto = server.protocol
      if let binder = await BinderRegistry.shared.binder(for: proto) {
        for (_, channel) in channels ?? [:] {
          for operation in expandOperations(in: channel, document: self) {
            try binder.bind(server: server, channel: channel, operation: operation, using: context)
          }
        }
      }
    }
  }
}
