import JSONSchema

public struct AsyncAPI: Codable, Sendable {
  /// The AsyncAPI specification version of this document.
  public let asyncapi: String

  /// A unique id representing the application.
  public let id: String?

  /// The object provides metadata about the API. The metadata can be used by the clients if needed.
  public let info: Info

  /// An object representing multiple servers.
  public let servers: [String: Server]?

  /// Default content type to use when encoding/decoding a message's payload.
  public let defaultContentType: String?

  /// A map of the available channels and their operations.
  public let channels: [String: Channel]?

  /// A map of the available operations and their operations.
  public let operations: [String: Operation]?

  /// An object to hold a set of reusable objects for different aspects of the AsyncAPI specification.
  public let components: Components?

  public init(
    asyncapi: String,
    id: String? = nil,
    info: Info,
    servers: [String: Server]? = nil,
    defaultContentType: String? = nil,
    channels: [String: Channel]? = nil,
    operations: [String: Operation]? = nil,
    components: Components? = nil
  ) {
    self.asyncapi = asyncapi
    self.id = id
    self.info = info
    self.servers = servers
    self.defaultContentType = defaultContentType
    self.channels = channels
    self.operations = operations
    self.components = components
  }
}

extension AsyncAPI {
  /// The object provides metadata about the API. The metadata can be used by the clients if needed.
  /// Example:
  /// ```json
  /// {
  ///   "title": "AsyncAPI Sample App",
  ///   "version": "1.0.1",
  ///   "description": "This is a sample app.",
  ///   "termsOfService": "https://asyncapi.org/terms/",
  ///   "contact": {
  ///     "name": "API Support",
  ///     "url": "https://www.asyncapi.org/support",
  ///     "email": "support@asyncapi.org"
  ///   },
  ///   "license": {
  ///     "name": "Apache 2.0",
  ///     "url": "https://www.apache.org/licenses/LICENSE-2.0.html"
  ///   },
  ///   "externalDocs": {
  ///     "description": "Find more info here",
  ///     "url": "https://www.asyncapi.org"
  ///   },
  ///   "tags": [
  ///     {
  ///       "name": "e-commerce"
  ///     }
  ///   ]
  /// }
  /// ```
  public struct Info: Codable, Sendable {
    /// A unique and precise title of the API.
    public let title: String

    /// A semantic version number of the API.
    public let version: String

    /// A longer description of the API. Should be different from the title. CommonMark is allowed.
    public let description: String?

    /// A URL to the Terms of Service for the API. MUST be in the format of a URL.
    public let termsOfService: String?

    /// Contact information for the exposed API.
    public let contact: Contact?

    /// License information for the exposed API.
    public let license: License?

    /// A list of tags for application API documentation control. Tags can be used for logical grouping of applications.
    public let tags: [Tag]?

    /// Additional external documentation.
    public let externalDocs: [ExternalDoc]?

    public init(
      title: String,
      version: String,
      description: String? = nil,
      termsOfService: String? = nil,
      contact: Contact? = nil,
      license: License? = nil,
      tags: [Tag]? = nil,
      externalDocs: [ExternalDoc]? = nil
    ) {
      self.title = title
      self.version = version
      self.description = description
      self.termsOfService = termsOfService
      self.contact = contact
      self.license = license
      self.tags = tags
      self.externalDocs = externalDocs
    }
  }

  /// Contact information for the exposed API.
  public struct Contact: Codable, Sendable {
    /// The identifying name of the contact person/organization.
    public let name: String?

    /// The URL pointing to the contact information.
    public let url: String?

    /// The email address of the contact person/organization.
    public let email: String?

    public init(name: String? = nil, url: String? = nil, email: String? = nil) {
      self.name = name
      self.url = url
      self.email = email
    }
  }

  /// License information for the exposed API.
  public struct License: Codable, Sendable {
    /// The name of the license type. It's encouraged to use an OSI compatible license.
    public let name: String

    /// The URL pointing to the license.
    public let url: String?

    public init(name: String, url: String? = nil) {
      self.name = name
      self.url = url
    }
  }

  /// Allows adding metadata to a single tag.
  public struct Tag: Codable, Sendable {
    /// The name of the tag.
    public let name: String

    /// A short description for the tag. CommonMark syntax can be used for rich text representation.
    public let descrtion: String?

    /// Additional external documentation.
    public let externalDocs: [ReferenceOr<ExternalDoc>]?

    public init(
      name: String,
      descrtion: String? = nil,
      externalDocs: [ReferenceOr<ExternalDoc>]? = nil
    ) {
      self.name = name
      self.descrtion = descrtion
      self.externalDocs = externalDocs
    }
  }

  /// Allows referencing an external resource for extended documentation.
  public struct ExternalDoc: Codable, Sendable {
    /// A short description of the target documentation. CommonMark syntax can be used for rich text representation.
    public let description: String?

    /// The URL for the target documentation. This MUST be in the form of an absolute URL.
    public let url: String

    public init(description: String? = nil, url: String) {
      self.description = description
      self.url = url
    }
  }

  /// An object representing a message broker, a server or any other kind of computer program capable of sending and/or receiving data.
  public struct Server: Codable, Sendable {
    /// The server host name. It MAY include the port. This field supports Server Variables. Variable substitutions will be made when a variable is named in {braces}.
    public let host: String

    /// The path to a resource in the host. This field supports Server Variables. Variable substitutions will be made when a variable is named in {braces}.
    public let pathname: String?

    /// A human-friendly title for the server.
    public let title: String?

    /// A brief summary of the server.
    public let summary: String?

    /// A longer description of the server. CommonMark is allowed.
    public let description: String?

    /// The protocol this server supports for connection.
    public let `protocol`: String

    /// An optional string describing the server. CommonMark syntax MAY be used for rich text representation.
    public let protocolVersion: String?

    /// Server variables for URL template substitution.
    public let variables: ServerVariable?

    /// Security requirements for this server.
    public let security: [ReferenceOr<SecurityRequirement>]?

    /// A list of tags for API documentation control.
    public let tags: [ReferenceOr<Tag>]?

    /// Additional external documentation.
    public let externalDocs: ReferenceOr<ExternalDoc>?

    /// Protocol-specific information for the server.
    public let bindings: JSONValue?

    public init(
      host: String,
      pathname: String? = nil,
      title: String? = nil,
      summary: String? = nil,
      description: String? = nil,
      protocol: String,
      protocolVersion: String? = nil,
      variables: ServerVariable? = nil,
      security: [ReferenceOr<SecurityRequirement>]? = nil,
      tags: [ReferenceOr<Tag>]? = nil,
      externalDocs: ReferenceOr<ExternalDoc>? = nil,
      bindings: JSONValue? = nil
    ) {
      self.host = host
      self.pathname = pathname
      self.title = title
      self.summary = summary
      self.description = description
      self.protocol = `protocol`
      self.protocolVersion = protocolVersion
      self.variables = variables
      self.security = security
      self.tags = tags
      self.externalDocs = externalDocs
      self.bindings = bindings
    }
  }

  /// An object representing a Server Variable for server URL template substitution.
  public struct ServerVariable: Codable, Sendable {
    /// An enumeration of string values to be used if the substitution options are from a limited set.
    public let `enum`: [String]?

    /// The default value to use for substitution, and to send, if an alternate value is not supplied.
    public let `default`: String?

    /// An optional description for the server variable. CommonMark syntax MAY be used for rich text representation.
    public let description: String?

    /// An array of examples of the server variable.
    public let examples: [String]?

    public init(
      enum: [String]? = nil,
      default: String? = nil,
      description: String? = nil,
      examples: [String]? = nil
    ) {
      self.enum = `enum`
      self.default = `default`
      self.description = description
      self.examples = examples
    }
  }

  /// Defines a security scheme that can be used by the operations.
  public struct SecurityRequirement: Codable, Sendable {
    /// The security requirements for this operation.
    public let requirements: [String: [String]]

    public init(requirements: [String: [String]]) {
      self.requirements = requirements
    }
  }

  /// Describes a shared communication channel.
  public struct Channel: Codable, Sendable {
    /// An optional string representation of this channel's address. The address is typically the "topic name", "routing key", "event type", or "path". When `null` or absent, it MUST be interpreted as unknown. This is useful when the address is generated dynamically at runtime or can't be known upfront. It MAY contain Channel Address Expressions.
    public let address: String?
    /// A human-friendly title for the channel.
    public let title: String?
    /// A brief summary of the channel.
    public let summary: String?
    /// A longer description of the channel. CommonMark is allowed.
    public let description: String?
    /// The references of the servers on which this channel is available. If absent or empty then this channel must be available on all servers.
    public let servers: [ReferenceOr<Server>]?
    /// A list of tags for logical grouping of channels.
    public let tags: [Tag]?
    /// Additional external documentation.
    public let externalDocs: ExternalDoc?
    /// Protocol-specific information for the channel.
    public let bindings: JSONValue?
    /// A map of the messages that will be sent to this channel by any application at any time. Every message sent to this channel MUST be valid against one, and only one, of the message objects defined in this map.
    public let messages: [String: ReferenceOr<Message>]?
    /// A map of the parameters for this channel.
    public let parameters: [String: ReferenceOr<Parameter>]?

    public init(
      address: String? = nil,
      title: String? = nil,
      summary: String? = nil,
      description: String? = nil,
      servers: [ReferenceOr<Server>]? = nil,
      tags: [Tag]? = nil,
      externalDocs: ExternalDoc? = nil,
      bindings: JSONValue? = nil,
      messages: [String: ReferenceOr<Message>]? = nil,
      parameters: [String: ReferenceOr<Parameter>]? = nil
    ) {
      self.address = address
      self.title = title
      self.summary = summary
      self.description = description
      self.servers = servers
      self.tags = tags
      self.externalDocs = externalDocs
      self.bindings = bindings
      self.messages = messages
      self.parameters = parameters
    }
  }

  /// Describes an operation (publish or subscribe) on a channel.
  public struct Operation: Codable, Sendable {
    /// The action to perform (send or receive).
    public let action: Action
    /// The channel this operation is associated with.
    public let channel: ReferenceOr<Channel>
    /// A list of message references for this operation.
    public let messages: [ReferenceOr<Message>]?
    /// Information about the reply to this operation.
    public let reply: OperationReply?
    /// A list of traits to apply to the operation object.
    public let traits: [ReferenceOr<OperationTrait>]?
    /// A human-friendly title for the operation.
    public let title: String?
    /// A brief summary of the operation.
    public let summary: String?
    /// A longer description of the operation. CommonMark is allowed.
    public let description: String?
    /// A declaration of which security mechanisms can be used for this operation.
    public let security: [SecurityRequirement]?
    /// A list of tags for logical grouping of operations.
    public let tags: [Tag]?
    /// Additional external documentation.
    public let externalDocs: ExternalDoc?
    /// Protocol-specific information for the operation.
    public let bindings: JSONValue?

    public init(
      action: Action,
      channel: ReferenceOr<Channel>,
      messages: [ReferenceOr<Message>]? = nil,
      reply: OperationReply? = nil,
      traits: [ReferenceOr<OperationTrait>]? = nil,
      title: String? = nil,
      summary: String? = nil,
      description: String? = nil,
      security: [SecurityRequirement]? = nil,
      tags: [Tag]? = nil,
      externalDocs: ExternalDoc? = nil,
      bindings: JSONValue? = nil
    ) {
      self.action = action
      self.channel = channel
      self.messages = messages
      self.reply = reply
      self.traits = traits
      self.title = title
      self.summary = summary
      self.description = description
      self.security = security
      self.tags = tags
      self.externalDocs = externalDocs
      self.bindings = bindings
    }
  }

  public enum Action: String, Codable, Sendable {
    case send
    case receive
  }

  public struct OperationReply: Codable, Sendable {
    public let channel: ReferenceOr<Channel>
    public let messages: [ReferenceOr<Message>]

    public init(channel: ReferenceOr<Channel>, messages: [ReferenceOr<Message>]) {
      self.channel = channel
      self.messages = messages
    }
  }

  /// Describes a system-specific unique identifier for correlating messages.
  public struct CorrelationId: Codable, Sendable {
    /// A longer description of the correlation ID. CommonMark is allowed.
    public let description: String?
    /// A runtime expression that specifies the location of the correlation ID value.
    public let location: String

    public init(description: String? = nil, location: String) {
      self.description = description
      self.location = location
    }
  }

  /// Holds a set of reusable objects for different aspects of the AsyncAPI specification.
  public struct Components: Codable, Sendable {
    /// A map of reusable Schema Objects.
    public let schemas: [String: JSONValue]?
    /// A map of reusable Message Objects.
    public let messages: [String: Message]?
    /// A map of reusable Security Scheme Objects.
    public let securitySchemes: [String: AsyncAPI.Server.SecurityScheme]?
    /// A map of reusable Parameter Objects.
    public let parameters: [String: Parameter]?
    /// A map of reusable Correlation ID Objects.
    public let correlationIds: [String: CorrelationId]?
    /// A map of reusable Operation Trait Objects.
    public let operationTraits: [String: OperationTrait]?
    /// A map of reusable Message Trait Objects.
    public let messageTraits: [String: MessageTrait]?
    /// A map of reusable Server Binding Objects.
    public let serverBindings: [String: JSONValue]?
    /// A map of reusable Channel Binding Objects.
    public let channelBindings: [String: JSONValue]?
    /// A map of reusable Operation Binding Objects.
    public let operationBindings: [String: JSONValue]?
    /// A map of reusable Message Binding Objects.
    public let messageBindings: [String: JSONValue]?

    public init(
      schemas: [String: JSONValue]? = nil,
      messages: [String: Message]? = nil,
      securitySchemes: [String: AsyncAPI.Server.SecurityScheme]? = nil,
      parameters: [String: Parameter]? = nil,
      correlationIds: [String: CorrelationId]? = nil,
      operationTraits: [String: OperationTrait]? = nil,
      messageTraits: [String: MessageTrait]? = nil,
      serverBindings: [String: JSONValue]? = nil,
      channelBindings: [String: JSONValue]? = nil,
      operationBindings: [String: JSONValue]? = nil,
      messageBindings: [String: JSONValue]? = nil
    ) {
      self.schemas = schemas
      self.messages = messages
      self.securitySchemes = securitySchemes
      self.parameters = parameters
      self.correlationIds = correlationIds
      self.operationTraits = operationTraits
      self.messageTraits = messageTraits
      self.serverBindings = serverBindings
      self.channelBindings = channelBindings
      self.operationBindings = operationBindings
      self.messageBindings = messageBindings
    }
  }

  /// Describes a trait that MAY be applied to an Operation Object.
  public struct OperationTrait: Codable, Sendable {
    /// A human-friendly title for the operation trait.
    public let title: String?
    /// A brief summary of the operation trait.
    public let summary: String?
    /// A longer description of the operation trait. CommonMark is allowed.
    public let description: String?
    /// A list of tags for logical grouping of operation traits.
    public let tags: [Tag]?
    /// Additional external documentation.
    public let externalDocs: ExternalDoc?
    /// Protocol-specific information for the operation trait.
    public let bindings: JSONValue?

    public init(
      title: String? = nil,
      summary: String? = nil,
      description: String? = nil,
      tags: [Tag]? = nil,
      externalDocs: ExternalDoc? = nil,
      bindings: JSONValue? = nil
    ) {
      self.title = title
      self.summary = summary
      self.description = description
      self.tags = tags
      self.externalDocs = externalDocs
      self.bindings = bindings
    }
  }

  /// Describes a message received on a given channel and operation.
  public struct Message: Codable, Sendable {
    /// The name of the message.
    public let name: String?
    /// The content type to use when encoding/decoding a message's payload. The value MUST be a specific media type (e.g. application/json). When omitted, the value MUST be the one specified on the defaultContentType field.
    public let contentType: String?
    /// Schema definition of the message headers.
    public let headers: JSONValue?
    /// Schema definition of the message payload.
    public let payload: JSONValue?
    /// Correlation ID information for the message.
    public let correlationId: CorrelationId?
    /// A human-friendly title for the message.
    public let title: String?
    /// A brief summary of the message.
    public let summary: String?
    /// A longer description of the message. CommonMark is allowed.
    public let description: String?
    /// A list of tags for logical grouping of messages.
    public let tags: [Tag]?
    /// Additional external documentation.
    public let externalDocs: ExternalDoc?
    /// Protocol-specific information for the message.
    public let bindings: JSONValue?
    /// List of examples.
    public let examples: [JSONValue]?

    public init(
      name: String? = nil,
      contentType: String? = nil,
      headers: JSONValue? = nil,
      payload: JSONValue? = nil,
      correlationId: CorrelationId? = nil,
      title: String? = nil,
      summary: String? = nil,
      description: String? = nil,
      tags: [Tag]? = nil,
      externalDocs: ExternalDoc? = nil,
      bindings: JSONValue? = nil,
      examples: [JSONValue]? = nil
    ) {
      self.name = name
      self.contentType = contentType
      self.headers = headers
      self.payload = payload
      self.correlationId = correlationId
      self.title = title
      self.summary = summary
      self.description = description
      self.tags = tags
      self.externalDocs = externalDocs
      self.bindings = bindings
      self.examples = examples
    }
  }

  /// Describes a parameter included in a channel address.
  public struct Parameter: Codable, Sendable {
    /// A longer description of the parameter. CommonMark is allowed.
    public let description: String?
    /// Schema definition of the parameter.
    public let schema: JSONValue?
    /// A runtime expression that specifies the location of the parameter value.
    public let location: String?

    public init(description: String? = nil, schema: JSONValue? = nil, location: String? = nil) {
      self.description = description
      self.schema = schema
      self.location = location
    }
  }

  /// Describes a trait that MAY be applied to a Message Object.
  public struct MessageTrait: Codable, Sendable {
    /// Schema definition of the message headers.
    public let headers: JSONValue?
    /// Correlation ID information for the message.
    public let correlationId: CorrelationId?
    /// The content type to use when encoding/decoding a message's payload.
    public let contentType: String?
    /// Name of the message.
    public let name: String?
    /// A human-friendly title for the message trait.
    public let title: String?
    /// A brief summary of the message trait.
    public let summary: String?
    /// A longer description of the message trait. CommonMark is allowed.
    public let description: String?
    /// A list of tags for logical grouping of message traits.
    public let tags: [Tag]?
    /// Additional external documentation.
    public let externalDocs: ExternalDoc?
    /// Protocol-specific information for the message trait.
    public let bindings: JSONValue?
    /// List of examples.
    public let examples: [JSONValue]?

    public init(
      headers: JSONValue? = nil,
      correlationId: CorrelationId? = nil,
      contentType: String? = nil,
      name: String? = nil,
      title: String? = nil,
      summary: String? = nil,
      description: String? = nil,
      tags: [Tag]? = nil,
      externalDocs: ExternalDoc? = nil,
      bindings: JSONValue? = nil,
      examples: [JSONValue]? = nil
    ) {
      self.headers = headers
      self.correlationId = correlationId
      self.contentType = contentType
      self.name = name
      self.title = title
      self.summary = summary
      self.description = description
      self.tags = tags
      self.externalDocs = externalDocs
      self.bindings = bindings
      self.examples = examples
    }
  }
}

extension AsyncAPI.Server {
  /// Protocol-specific information for the server.
  public struct Binding: Codable, Sendable {
    /// The binding value.
    public let value: JSONValue

    public init(value: JSONValue) {
      self.value = value
    }
  }

  /// Defines a security scheme that can be used by the operations.
  public enum SecurityScheme: Codable, Sendable {
    /// User/password security scheme.
    case userPassword(description: String?, scheme: String)
    /// API key security scheme.
    case apiKey(description: String?, name: String, in: String)
    /// X509 security scheme.
    case x509(description: String?)
    /// Symmetric encryption security scheme.
    case symmetricEncryption(description: String?, scheme: String)
    /// Asymmetric encryption security scheme.
    case asymmetricEncryption(description: String?, scheme: String)
    /// HTTP security scheme.
    case httpSecurityScheme(description: String?, scheme: String, bearerFormat: String?)
    /// OAuth2 flows security scheme.
    case oauth2Flows(description: String?, flows: OAuth2Flows)
    /// OpenID Connect security scheme.
    case openIdConnect(description: String?, openIdConnectUrl: String)
    /// SASL security scheme.
    case saslSecurityScheme(description: String?, type: String)

    private enum CodingKeys: String, CodingKey {
      case type
      case description
      case scheme
      case name
      case `in`
      case bearerFormat
      case flows
      case openIdConnectUrl
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let type = try container.decode(String.self, forKey: .type)
      let description = try container.decodeIfPresent(String.self, forKey: .description)

      switch type {
      case "userPassword":
        let scheme = try container.decode(String.self, forKey: .scheme)
        self = .userPassword(description: description, scheme: scheme)
      case "apiKey":
        let name = try container.decode(String.self, forKey: .name)
        let `in` = try container.decode(String.self, forKey: .in)
        self = .apiKey(description: description, name: name, in: `in`)
      case "X509":
        self = .x509(description: description)
      case "symmetricEncryption":
        let scheme = try container.decode(String.self, forKey: .scheme)
        self = .symmetricEncryption(description: description, scheme: scheme)
      case "asymmetricEncryption":
        let scheme = try container.decode(String.self, forKey: .scheme)
        self = .asymmetricEncryption(description: description, scheme: scheme)
      case "http":
        let scheme = try container.decode(String.self, forKey: .scheme)
        let bearerFormat = try container.decodeIfPresent(String.self, forKey: .bearerFormat)
        self = .httpSecurityScheme(
          description: description,
          scheme: scheme,
          bearerFormat: bearerFormat
        )
      case "oauth2":
        let flows = try container.decode(OAuth2Flows.self, forKey: .flows)
        self = .oauth2Flows(description: description, flows: flows)
      case "openIdConnect":
        let openIdConnectUrl = try container.decode(String.self, forKey: .openIdConnectUrl)
        self = .openIdConnect(description: description, openIdConnectUrl: openIdConnectUrl)
      case "scramSha256", "scramSha512", "plain", "gssapi":
        self = .saslSecurityScheme(description: description, type: type)
      default:
        throw DecodingError.dataCorruptedError(
          forKey: .type,
          in: container,
          debugDescription: "Unknown security scheme type: \(type)"
        )
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      switch self {
      case .userPassword(let description, let scheme):
        try container.encode("userPassword", forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(scheme, forKey: .scheme)
      case .apiKey(let description, let name, let in_):
        try container.encode("apiKey", forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(name, forKey: .name)
        try container.encode(in_, forKey: .in)
      case .X509(let description):
        try container.encode("X509", forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
      case .symmetricEncryption(let description, let scheme):
        try container.encode("symmetricEncryption", forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(scheme, forKey: .scheme)
      case .asymmetricEncryption(let description, let scheme):
        try container.encode("asymmetricEncryption", forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(scheme, forKey: .scheme)
      case .HTTPSecurityScheme(let description, let scheme, let bearerFormat):
        try container.encode("http", forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(scheme, forKey: .scheme)
        try container.encodeIfPresent(bearerFormat, forKey: .bearerFormat)
      case .oauth2Flows(let description, let flows):
        try container.encode("oauth2", forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(flows, forKey: .flows)
      case .openIdConnect(let description, let openIdConnectUrl):
        try container.encode("openIdConnect", forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(openIdConnectUrl, forKey: .openIdConnectUrl)
      case .saslSecurityScheme(let description, let type):
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(description, forKey: .description)
      }
    }
  }

  /// OAuth2 flows configuration.
  public struct OAuth2Flows: Codable, Sendable {
    /// Implicit OAuth2 flow.
    public let implicit: OAuth2Flow?
    /// Password OAuth2 flow.
    public let password: OAuth2Flow?
    /// Client credentials OAuth2 flow.
    public let clientCredentials: OAuth2Flow?
    /// Authorization code OAuth2 flow.
    public let authorizationCode: OAuth2Flow?

    public init(
      implicit: OAuth2Flow? = nil,
      password: OAuth2Flow? = nil,
      clientCredentials: OAuth2Flow? = nil,
      authorizationCode: OAuth2Flow? = nil
    ) {
      self.implicit = implicit
      self.password = password
      self.clientCredentials = clientCredentials
      self.authorizationCode = authorizationCode
    }
  }

  /// OAuth2 flow configuration.
  public struct OAuth2Flow: Codable, Sendable {
    /// The authorization URL for this flow.
    public let authorizationUrl: String?
    /// The token URL for this flow.
    public let tokenUrl: String?
    /// The refresh URL for this flow.
    public let refreshUrl: String?
    /// The available scopes for this flow.
    public let scopes: [String: String]

    public init(
      authorizationUrl: String? = nil,
      tokenUrl: String? = nil,
      refreshUrl: String? = nil,
      scopes: [String: String]
    ) {
      self.authorizationUrl = authorizationUrl
      self.tokenUrl = tokenUrl
      self.refreshUrl = refreshUrl
      self.scopes = scopes
    }
  }
}
