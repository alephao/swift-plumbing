import Dependencies
import Logging

public enum MainLoggerKey: DependencyKey {
  public static var liveValue: Logger = {
    var logger = Logger(label: "Server")
    logger.logLevel = .debug
    return logger
  }()
  public static var testValue: Logger = Logger(label: "Server")
}

extension DependencyValues {
  public var logger: Logger {
    get { self[MainLoggerKey.self] }
    set { self[MainLoggerKey.self] = newValue }
  }
}
