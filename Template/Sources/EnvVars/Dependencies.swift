import Dependencies

extension EnvVars: TestDependencyKey {
  public static var testValue: EnvVars = .init()
}

extension DependencyValues {
  public var envVars: EnvVars {
    get { self[EnvVars.self] }
    set { self[EnvVars.self] = newValue }
  }
}
