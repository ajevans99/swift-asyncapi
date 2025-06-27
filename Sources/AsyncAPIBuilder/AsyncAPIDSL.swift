import AsyncAPIGenerator
import JSONSchema
import JSONSchemaBuilder

// MARK: AsyncAPI DSL  ─ one builder all the way down
@resultBuilder
public enum AsyncAPIDSL {
  public typealias Partial = AsyncAPIBuilder

  // leaf expressions
  public static func buildExpression(_ info: Info) -> Partial {
    var b = AsyncAPIBuilder()
    b.info = info.finish()
    return b
  }

  public static func buildExpression(_ server: Server) -> Partial {
    var b = AsyncAPIBuilder()
    b.servers[server.key] = server.finish()
    return b
  }

  public static func buildExpression(_ channel: Channel) -> Partial {
    var b = AsyncAPIBuilder()
    b.channels[channel.key] = channel.finish()
    for (k, op) in channel.operations { b.operations[k] = op }
    return b
  }

  public static func buildExpression(_ op: Operation) -> Partial {
    var b = AsyncAPIBuilder()
    b.operations[op.key] = op.finish()
    return b
  }

  public static func buildExpression(_ msg: Message) -> Partial {
    var b = AsyncAPIBuilder()
    b.componentsBuilder.addMessage(msg)
    return b
  }

  public static func buildExpression(_ schema: Schema) -> Partial {
    var b = AsyncAPIBuilder()
    b.componentsBuilder.addSchema(schema)
    return b
  }

  // plain sequencing (comma-separated lines)
  public static func buildBlock(_ parts: Partial...) -> Partial {
    parts.reduce(into: AsyncAPIBuilder()) { $0.merge(with: $1) }
  }

  // `for … in` loops
  public static func buildArray(_ parts: [Partial]) -> Partial {
    parts.reduce(into: AsyncAPIBuilder()) { $0.merge(with: $1) }
  }

  // conditionals
  public static func buildEither(first p: Partial) -> Partial { p }
  public static func buildEither(second p: Partial) -> Partial { p }

  // optional blocks
  public static func buildOptional(_ p: Partial?) -> Partial {
    p ?? AsyncAPIBuilder()
  }

  // final conversion
  public static func buildFinalResult(_ b: Partial) -> AsyncAPI {
    b.finish()
  }
}

public enum AsyncAPIComponent {
  case info(AsyncAPIGenerator.AsyncAPI.Info)
  case server(Server)
  case channel(Channel)
  case operation(Operation)
  case message(Message)
  case schema(Schema)
}

extension AsyncAPIBuilder {
  static func from(_ c: AsyncAPIComponent) -> Self {
    var b = Self()
    b.apply(c)
    return b
  }

  mutating func apply(_ c: AsyncAPIComponent) {
    switch c {
    case .info(let info):
      self.info = info
    case .server(let s):
      servers[s.key] = s.finish()
    case .channel(let ch):
      channels[ch.key] = ch.finish()
      for (k, op) in ch.operations { operations[k] = op }
    case .operation(let op):
      operations[op.key] = op.finish()
    case .message(let m):
      componentsBuilder.addMessage(m)
    case .schema(let s):
      componentsBuilder.addSchema(s)
    }
  }
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
  var componentsBuilder = ComponentsBuilder()

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

  public mutating func merge(with other: AsyncAPIBuilder) {
    if !other.info.title.isEmpty { info = other.info }
    if let v = other.id { id = v }
    if let v = other.defaultContentType { defaultContentType = v }

    servers.merge(other.servers) { _, new in new }
    channels.merge(other.channels) { _, new in new }
    operations.merge(other.operations) { _, new in new }
    componentsBuilder.merge(other.componentsBuilder)
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
      components: componentsBuilder.finish()
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
  private let builder: ChannelBuilder

  public init(key: String, address: String) {
    self.key = key
    self.builder = ChannelBuilder(address: address)
  }

  public init(_ address: String, build: (inout ChannelBuilder) -> Void) {
    self.key = address
    var b = ChannelBuilder(address: address)
    build(&b)
    self.builder = b
  }

  var operations: [String: AsyncAPI.Operation] {
    builder.buildOperations(channelKey: key)
  }

  public func finish() -> AsyncAPI.Channel {
    builder.finish()
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

  public func messages(_ messages: [Message]) -> Self {
    var copy = self
    copy.messages = messages.map { .value($0.finish()) }
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
