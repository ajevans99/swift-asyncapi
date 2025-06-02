import Foundation

public enum ReferenceOr<Value: Codable & Sendable>: Codable, Sendable {
  case reference(String)
  case value(Value)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let ref = try? container.decode(String.self) {
      self = .reference(ref)
    } else if let refObject = try? container.decode([String: String].self),
      let ref = refObject["$ref"]
    {
      self = .reference(ref)
    } else {
      let value = try container.decode(Value.self)
      self = .value(value)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .reference(let ref):
      try container.encode(["$ref": ref])
    case .value(let value):
      try container.encode(value)
    }
  }
}
