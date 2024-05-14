import Foundation
import URLRouting

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct PlumbingRouter<Router: ParserPrinter>: ParserPrinter
where Router.Input == URLRequestData {
  let _baseURL: String
  let _makeRouter: () -> Router

  public init(
    baseURL: URL = URL(string: "http://localhost:8080")!,
    router: @escaping () -> Router
  ) {
    self._baseURL = baseURL.absoluteString
    self._makeRouter = router
  }

  public func parse(_ input: inout URLRequestData) throws -> Router.Output {
    try _makeRouter().parse(&input)
  }

  public func print(_ output: Router.Output, into input: inout URLRequestData) throws {
    try _makeRouter()
      .baseURL(self._baseURL)
      .print(output, into: &input)
  }

  public func url(for route: Router.Output) -> String {
    self.url(for: route).absoluteString
  }
}

// TODO: Middleware to inject Ctx? Codegen?
