import AsyncAPIGenerator

public actor RuntimeRegistry {
  public static let shared = RuntimeRegistry()
  private init() {}

  private var document: AsyncAPI?
  private var operations: [String: OperationRuntime] = [:]

  public func setDocument(_ document: AsyncAPI) {
    self.document = document
  }

  public func getDocument() -> AsyncAPI? {
    document
  }

  public func registerOperation(_ key: String, runtime: OperationRuntime) {
    operations[key] = runtime
  }

  public func operationRuntime(for key: String) -> OperationRuntime? {
    operations[key]
  }
}
