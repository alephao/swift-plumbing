import Dependencies
import Hummingbird
import Logging

public enum AppEnv: String, Codable {
  case development
  case production
  case staging
  case testing
}

extension AppEnv: DependencyKey {
  public static var liveValue: AppEnv = .development
  public static var testValue: AppEnv = .testing
}

extension DependencyValues {
  public var appEnv: AppEnv {
    get { self[AppEnv.self] }
    set { self[AppEnv.self] = newValue }
  }
}

extension DependencyValues {
  public var logger: Logger {
    get { self[LoggerKey.self] }
    set { self[LoggerKey.self] = newValue }
  }
}

private enum LoggerKey: DependencyKey {
  static let liveValue = {
    @Dependency(\.appEnv) var env
    var logger = Logger(label: "Plumbing")
    if env == .development {
      logger.logLevel = .debug
    }
    return logger
  }()
  static let testValue = Logger(label: "Plumbing")
}

extension Request: DependencyKey {
  public static var liveValue: Request { fatalError("Request not set") }
  public static var testValue: Request { fatalError("Request not set") }
}

extension DependencyValues {
  public var req: Request {
    get { self[Request.self] }
    set { self[Request.self] = newValue }
  }
}

extension PlumbingRequestContext: DependencyKey {
  public static var liveValue: PlumbingRequestContext { fatalError("RequestContext not set") }
  public static var testValue: PlumbingRequestContext { fatalError("RequestContext not set") }
}

extension DependencyValues {
  public var ctx: PlumbingRequestContext {
    get { self[PlumbingRequestContext.self] }
    set { self[PlumbingRequestContext.self] = newValue }
  }
}
