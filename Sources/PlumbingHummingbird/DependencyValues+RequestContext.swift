import Dependencies

extension PlumbingRequestContext: TestDependencyKey {
  public static var liveValue: PlumbingRequestContext {
    fatalError("PlumbingRequestContext.liveValue not set")
  }
  public static var testValue: PlumbingRequestContext {
    fatalError("PlumbingRequestContext.testValue not set")
  }
}

extension DependencyValues {
  public var ctx: PlumbingRequestContext {
    get { self[PlumbingRequestContext.self] }
    set { self[PlumbingRequestContext.self] = newValue }
  }
}
