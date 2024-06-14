import Dependencies
import Deps  // Deps export Router and EnvVars
import Hummingbird
import LoggerMiddleware
import Logging
import Plumbing
import PlumbingHummingbird
import PublicAssets
import PublicAssetsMiddleware

func makeLogger(label: String) -> Logger {
  var logger = Logger(label: label)
  #if DEBUG
    logger.logLevel = .debug
  #endif
  return logger
}

public func buildApplication() -> some ApplicationProtocol {
  @Dependency(\.logger) var logger
  @Dependency(\.envVars) var envVars

  let publicAssetsLogger = makeLogger(label: "PublicAssets")

  let middleware: PlumbingHummingbird.Middleware =
    loggerMiddleware(logger: logger)
    <<< publicAssetsMiddleware(
      localFileSystem: LocalFileSystem(
        rootFolder: "public",
        threadPool: .singleton,
        logger: publicAssetsLogger
      ),
      logger: publicAssetsLogger,
      getFilePath: { publicAssetsMapping[$0] },
      cache: envVars.appEnv == .prod
        ? .immutable
        : .noCache
    )
    <<< routerMiddleware(logger: makeLogger(label: "Router"))

  let router = PlumbingResponderBuilder(handler: middleware(rootHandler))

  let app = Application(
    router: router,
    configuration: .init(address: .hostname(envVars.host, port: envVars.port)),
    logger: logger
  )

  return app
}
