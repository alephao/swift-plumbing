import Foundation
import Hummingbird
import Logging

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public func loggerMiddleware(logger: Logger) -> PlumbingHTTPMiddleware {
  { next in
    {
      let req = Ctx.req

      // FIXME: Make UUID and Date mockable
      let requestID = UUID()
      let startTime = Date().timeIntervalSince1970
      logger.log(
        level: .info,
        """
        \(requestID) [Req] \(req.method) \
        \(req.uri.path)
        """
      )
      let res = await next()
      let endTime = Date().timeIntervalSince1970
      logger.log(
        level: .info,
        "\(requestID) [Res] \(res.status.code) in \(Int((endTime - startTime) * 1000))ms"
      )
      return res
    }
  }
}
