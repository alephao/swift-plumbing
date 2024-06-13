import Foundation

import protocol URLRouting.ParserPrinter
import struct URLRouting.URLRequestData

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct Router: ParserPrinter {
  public typealias Input = URLRequestData
  public typealias Output = Route

  private let baseURL: URL
  private let rootRouter: RootRouter

  public init(baseURL: URL, rootRouter: RootRouter) {
    self.baseURL = baseURL
    self.rootRouter = rootRouter
  }

  public func parse(_ input: inout Input) throws -> Output {
    try rootRouter.parse(&input)
  }

  public func print(_ output: Output, into input: inout Input) throws {
    try rootRouter
      .baseURL(self.baseURL.absoluteString)
      .print(output, into: &input)
  }

  public func url(for route: Output) -> String {
    self.url(for: route).absoluteString
  }
}
