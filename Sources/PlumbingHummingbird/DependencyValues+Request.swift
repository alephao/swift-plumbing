import Dependencies

import struct Hummingbird.Request

extension Request: TestDependencyKey {
  public static var liveValue: Request { fatalError("Request.liveValue not set") }
  public static var testValue: Request { fatalError("Request.testValue not set") }
}

extension DependencyValues {
  public var req: Request {
    get { self[Request.self] }
    set { self[Request.self] = newValue }
  }
}
