import AsyncAPIGenerator
import JSONSchema
import JSONSchemaBuilder

public struct ComponentsBuilder {
  var schemas: [String: JSONValue] = [:]
  var messages: [String: AsyncAPI.Message] = [:]

  mutating func addSchema(_ schema: Schema) {
    schemas[schema.key] = schema.finish()
  }

  mutating func addMessage(_ message: Message) {
    messages[message.key] = message.finish()
  }

  func finish() -> AsyncAPI.Components? {
    if schemas.isEmpty && messages.isEmpty { return nil }
    return AsyncAPI.Components(
      schemas: schemas.isEmpty ? nil : schemas,
      messages: messages.isEmpty ? nil : messages
    )
  }
}

public struct Schema {
  let key: String
  private var value: JSONValue

  public init(key: String, value: JSONValue = .object([:])) {
    self.key = key
    self.value = value
  }

  public init(key: String, @JSONSchemaBuilder _ build: () -> some JSONSchemaComponent) {
    self.key = key
    self.value = build().schemaValue.value
  }

  public func value(_ value: JSONValue) -> Self {
    var copy = self
    copy.value = value
    return copy
  }

  public func value(@JSONSchemaBuilder _ build: () -> some JSONSchemaComponent) -> Self {
    var copy = self
    copy.value = build().schemaValue.value
    return copy
  }

  func finish() -> JSONValue { value }
}

extension Schema {
  /// Create a schema component using a type conforming to ``Schemable``.
  ///
  /// - Parameters:
  ///   - key: The components dictionary key.
  ///   - type: The ``Schemable`` type describing the JSON Schema.
  public init<T: Schemable>(key: String, for type: T.Type) {
    self.key = key
    self.value = type.schema.schemaValue.value
  }
}

public struct Message {
  let key: String
  private var name: String?
  private var contentType: String?
  private var headers: JSONValue?
  private var payload: JSONValue?
  private var correlationId: AsyncAPI.CorrelationId?
  private var title: String?
  private var summary: String?
  private var description: String?
  private var tags: [AsyncAPI.Tag]?
  private var externalDocs: AsyncAPI.ExternalDoc?
  private var bindings: JSONValue?
  private var examples: [JSONValue]?

  public init(key: String) { self.key = key }

  public func name(_ value: String) -> Self {
    var copy = self
    copy.name = value
    return copy
  }

  public func contentType(_ value: String) -> Self {
    var copy = self
    copy.contentType = value
    return copy
  }

  public func headers(_ value: JSONValue) -> Self {
    var copy = self
    copy.headers = value
    return copy
  }

  public func headers(@JSONSchemaBuilder _ build: () -> some JSONSchemaComponent) -> Self {
    var copy = self
    copy.headers = build().schemaValue.value
    return copy
  }

  /// Apply a headers schema from a ``Schemable`` type.
  public func headers<T: Schemable>(_ type: T.Type) -> Self {
    headers(type.schema.schemaValue.value)
  }

  public func payload(_ value: JSONValue) -> Self {
    var copy = self
    copy.payload = value
    return copy
  }

  public func payload(@JSONSchemaBuilder _ build: () -> some JSONSchemaComponent) -> Self {
    var copy = self
    copy.payload = build().schemaValue.value
    return copy
  }

  /// Apply a payload schema from a ``Schemable`` type.
  public func payload<T: Schemable>(_ type: T.Type) -> Self {
    payload(type.schema.schemaValue.value)
  }

  public func correlationId(_ value: AsyncAPI.CorrelationId) -> Self {
    var copy = self
    copy.correlationId = value
    return copy
  }

  public func title(_ value: String) -> Self {
    var copy = self
    copy.title = value
    return copy
  }

  public func summary(_ value: String) -> Self {
    var copy = self
    copy.summary = value
    return copy
  }

  public func description(_ value: String) -> Self {
    var copy = self
    copy.description = value
    return copy
  }

  public func tags(_ value: [AsyncAPI.Tag]) -> Self {
    var copy = self
    copy.tags = value
    return copy
  }

  public func externalDocs(_ value: AsyncAPI.ExternalDoc) -> Self {
    var copy = self
    copy.externalDocs = value
    return copy
  }

  public func bindings(_ value: JSONValue) -> Self {
    var copy = self
    copy.bindings = value
    return copy
  }

  public func examples(_ value: [JSONValue]) -> Self {
    var copy = self
    copy.examples = value
    return copy
  }

  func finish() -> AsyncAPI.Message {
    AsyncAPI.Message(
      name: name,
      contentType: contentType,
      headers: headers,
      payload: payload,
      correlationId: correlationId,
      title: title,
      summary: summary,
      description: description,
      tags: tags,
      externalDocs: externalDocs,
      bindings: bindings,
      examples: examples
    )
  }
}

extension SchemaValue {
  public var jsonValue: JSONValue {
    switch self {
    case .boolean(let bool): return .boolean(bool)
    case .object(let dict): return .object(dict)
    }
  }
}

extension Schemable {
  /// The generated JSON Schema for this type as a ``JSONValue``.
  public static var jsonSchema: JSONValue { schema.schemaValue.value }
}
