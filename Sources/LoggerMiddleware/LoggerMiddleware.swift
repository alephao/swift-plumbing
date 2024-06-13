import Dependencies
import Foundation
import Logging
import PlumbingHummingbird

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public func loggerMiddleware(logger: Logger) -> Middleware {
  { next in
    { req, ctx in
      @Dependency(\.uuid) var uuid
      @Dependency(\.date) var date

      let requestID = uuid()
      let startTime = date().timeIntervalSince1970
      let res = await next(req, ctx)
      let endTime = date().timeIntervalSince1970
      let timeDiff = formatSecondsToDisplay(endTime - startTime)

      logger.log(
        level: .info,
        """
        \(requestID) \
        \(res.status.code) \
        in \(timeDiff) \
        \(req.method) \
        \(req.uri.path)
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
