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
      let timeDiff = formatSecondsToDisplay(endTime - startTime)

      logger.log(
        level: .info,
        """
        \(requestID) [Res] \(res.status.code) \
        in \(timeDiff)
        """
      )
      return res
    }
  }
}

private func formatSecondsToDisplay(_ timeInterval: TimeInterval) -> String {
  if timeInterval >= 1 {
    return "\(timeInterval)s"
  }

  if timeInterval >= 0.001 {
    return "\(Int(timeInterval * 1_000))ms"
  }

  if timeInterval >= 0.000001 {
    return "\(Int(timeInterval * 1_000_000))µs"
  }

  if timeInterval >= 0.000000001 {
    return "\(Int(timeInterval * 1_000_000))µs"
  }

  return "\(Int(timeInterval * 1_000_000_000))ns"
}
