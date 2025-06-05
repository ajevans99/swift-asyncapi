import AsyncAPIGenerator

public actor RuntimeRegistry {
  public static let shared = RuntimeRegistry()
  private init() {}

  private var document: AsyncAPI?

  public func setDocument(_ document: AsyncAPI) {
    self.document = document
  }

  public func getDocument() -> AsyncAPI? {
    document
  }
}
