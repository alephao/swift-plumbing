import Dependencies
import Hummingbird
import Plumbing
import ServiceLifecycle

public func startServer(
  host: String = "127.0.0.1",
  port: Int = 8080,
  services: [any Service] = [],
  handler: @escaping PlumbingHTTPHandler
) async throws {
  let app = buildApplication(
    host: host,
    port: port,
    services: services,
    handler: handler
  )
  try await app.runService()
}

public func buildApplication(
  host: String = "127.0.0.1",
  port: Int = 8080,
  services: [any Service] = [],
  handler: @escaping PlumbingHTTPHandler
) -> some ApplicationProtocol {
  @Dependency(\.logger) var logger
  let router = PlumbingResponderBuilder(handler: handler)

  var app = Application(
    router: router,
    configuration: .init(address: .hostname(host, port: port)),
    logger: logger
  )
  for service in app.services {
    app.addServices(service)
  }
  return app
}
