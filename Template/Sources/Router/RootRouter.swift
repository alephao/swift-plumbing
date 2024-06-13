import Dependencies
import URLRouting

public struct RootRouter: ParserPrinter {
  public init() {}
  public var body: some URLRouting.Router<Route> {
    OneOf {
      URLRouting.Route(.case(Route.home))

      URLRouting.Route(.case(Route.healthcheck)) {
        Path { "healthcheck" }
      }
    }
  }
}
