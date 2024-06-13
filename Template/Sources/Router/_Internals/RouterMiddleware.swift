import Dependencies
import Logging
import PlumbingHummingbird

import struct URLRouting.URLRequestData

private enum RouterMiddlewareError: Error {
  case invalidUri(String)
}

public func routerMiddleware(logger: Logger) -> Middleware {
  { next in
    { req, ctx in
      @Dependency(\.router) var router

      do {
        guard var reqData = URLRequestData(string: req.uri.description) else {
          throw RouterMiddlewareError.invalidUri(req.uri.description)
        }
        reqData.method = req.method.rawValue
        // TODO: Add other http fields to URLRequestData
        let route = try router.parse(&reqData)

        return await withDependencies {
          $0.route = route
        } operation: {
          return await next(req, ctx)
        }
      } catch {
        logger.debug("\(String(describing: error))")
        return .init(status: .notFound)
      }
    }
  }
}
