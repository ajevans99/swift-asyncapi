import AsyncAPIGenerator
import JSONSchema

@resultBuilder
public enum AsyncAPIDSL {
  public static func buildBlock(_ components: AsyncAPIComponent...) -> AsyncAPI {
    var builder = AsyncAPIBuilder()

    for component in components {
      switch component {
      case .info(let info):
        builder.info = info
      case .server(let server):
        builder.servers[server.key] = server.finish()
      case .channel(let channel):
        builder.channels[channel.key] = channel.finish()
      case .operation(let operation):
        builder.operations[operation.key] = operation.finish()
      }
    }

    return builder.finish()
  }

  public static func buildExpression(_ info: Info) -> AsyncAPIComponent {
    .info(info.finish())
  }

  public static func buildExpression(_ server: Server) -> AsyncAPIComponent {
    .server(server)
  }

  public static func buildExpression(_ channel: Channel) -> AsyncAPIComponent {
    .channel(channel)
  }

  public static func buildExpression(_ operation: Operation) -> AsyncAPIComponent {
    .operation(operation)
  }
}

public enum AsyncAPIComponent {
  case info(AsyncAPIGenerator.AsyncAPI.Info)
  case server(Server)
  case channel(Channel)
  case operation(Operation)
}

public struct AsyncAPIDocument {
  public let asyncapi: AsyncAPI

  public init(@AsyncAPIDSL _ build: () -> AsyncAPI) {
    self.asyncapi = build()
  }
}

public struct AsyncAPIBuilder {
  var asyncapi: String
  var id: String?
  var info: AsyncAPI.Info
  var servers: [String: AsyncAPI.Server] = [:]
  var defaultContentType: String?
  var channels: [String: AsyncAPI.Channel] = [:]
  var operations: [String: AsyncAPI.Operation] = [:]
  var components: AsyncAPI.Components?

  public init(version: String = "3.0.0") {
    self.asyncapi = version
    self.info = AsyncAPI.Info(title: "", version: "")
  }

  public func id(_ id: String) -> Self {
    var copy = self
    copy.id = id
    return copy
  }

  public func defaultContentType(_ contentType: String) -> Self {
    var copy = self
    copy.defaultContentType = contentType
    return copy
  }

  public func finish() -> AsyncAPI {
    AsyncAPI(
      asyncapi: asyncapi,
      id: id,
      info: info,
      servers: servers.isEmpty ? nil : servers,
      defaultContentType: defaultContentType,
      channels: channels.isEmpty ? nil : channels,
      operations: operations.isEmpty ? nil : operations,
      components: components
    )
  }
}

// MARK: - Info
public struct Info {
  private var title: String
  private var version: String
  private var description: String?
  private var tags: [AsyncAPI.Tag]?

  public init(title: String, version: String) {
    self.title = title
    self.version = version
  }

  public func description(_ description: String) -> Self {
    var copy = self
    copy.description = description
    return copy
  }

  public func tags(_ tags: [AsyncAPI.Tag]) -> Self {
    var copy = self
    copy.tags = tags
    return copy
  }

  public func finish() -> AsyncAPI.Info {
    AsyncAPI.Info(
      title: title,
      version: version,
      description: description,
      tags: tags
    )
  }
}

// MARK: - Server
public struct Server {
  let key: String
  private let url: String
  private var `protocol`: String?
  private var description: String?

  public init(key: String, url: String) {
    self.key = key
    self.url = url
  }

  public func `protocol`(_ value: String) -> Self {
    var copy = self
    copy.`protocol` = value
    return copy
  }

  public func description(_ description: String) -> Self {
    var copy = self
    copy.description = description
    return copy
  }

  public func finish() -> AsyncAPI.Server {
    AsyncAPI.Server(
      host: url,
      description: description,
      protocol: `protocol` ?? "wss"
    )
  }
}

// MARK: - Channel
public struct Channel {
  let key: String
  private let address: String

  public init(key: String, address: String) {
    self.key = key
    self.address = address
  }

  public func finish() -> AsyncAPI.Channel {
    AsyncAPI.Channel(
      address: address
    )
  }
}

// MARK: - Operation
public struct Operation {
  let key: String
  private let action: AsyncAPI.Action
  private var channel: ReferenceOr<AsyncAPI.Channel>?
  private var messages: [ReferenceOr<AsyncAPI.Message>]?
  private var reply: AsyncAPI.OperationReply?
  private var traits: [ReferenceOr<AsyncAPI.OperationTrait>]?
  private var title: String?
  private var summary: String?
  private var description: String?
  private var security: [AsyncAPI.SecurityRequirement]?
  private var tags: [AsyncAPI.Tag]?
  private var externalDocs: AsyncAPI.ExternalDoc?
  private var bindings: JSONValue?

  public init(key: String, action: AsyncAPI.Action) {
    self.key = key
    self.action = action
  }

  public func channel(_ channel: AsyncAPI.Channel) -> Self {
    var copy = self
    copy.channel = .value(channel)
    return copy
  }

  public func channel(ref: String) -> Self {
    var copy = self
    copy.channel = .reference(ref)
    return copy
  }

  public func messages(_ messages: [AsyncAPI.Message]) -> Self {
    var copy = self
    copy.messages = messages.map { .value($0) }
    return copy
  }

  public func messages(refs: [String]) -> Self {
    var copy = self
    copy.messages = refs.map { .reference($0) }
    return copy
  }

  public func reply(_ reply: AsyncAPI.OperationReply) -> Self {
    var copy = self
    copy.reply = reply
    return copy
  }

  public func traits(_ traits: [AsyncAPI.OperationTrait]) -> Self {
    var copy = self
    copy.traits = traits.map { .value($0) }
    return copy
  }

  public func traits(refs: [String]) -> Self {
    var copy = self
    copy.traits = refs.map { .reference($0) }
    return copy
  }

  public func title(_ title: String) -> Self {
    var copy = self
    copy.title = title
    return copy
  }

  public func summary(_ summary: String) -> Self {
    var copy = self
    copy.summary = summary
    return copy
  }

  public func description(_ description: String) -> Self {
    var copy = self
    copy.description = description
    return copy
  }

  public func security(_ security: [AsyncAPI.SecurityRequirement]) -> Self {
    var copy = self
    copy.security = security
    return copy
  }

  public func tags(_ tags: [AsyncAPI.Tag]) -> Self {
    var copy = self
    copy.tags = tags
    return copy
  }

  public func externalDocs(_ externalDocs: AsyncAPI.ExternalDoc) -> Self {
    var copy = self
    copy.externalDocs = externalDocs
    return copy
  }

  public func bindings(_ bindings: JSONValue) -> Self {
    var copy = self
    copy.bindings = bindings
    return copy
  }

  public func finish() -> AsyncAPI.Operation {
    AsyncAPI.Operation(
      action: action,
      channel: channel ?? .reference("#/channels/\(key)"),
      messages: messages,
      reply: reply,
      traits: traits,
      title: title,
      summary: summary,
      description: description,
      security: security,
      tags: tags,
      externalDocs: externalDocs,
      bindings: bindings
    )
  }
}
