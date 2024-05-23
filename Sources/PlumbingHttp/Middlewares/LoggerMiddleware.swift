import struct Logging.Logger

#if canImport(FoundationNetworking)
  import struct FoundationNetworking.UUID
  import struct FoundationNetworking.Date
  import typealias FoundationNetworking.TimeInterval
#else
  import struct Foundation.UUID
  import struct Foundation.Date
  import typealias Foundation.TimeInterval
#endif

public func loggerMiddleware(logger: Logger) -> PlumbingHTTPMiddleware {
  { next in
    {
      let req = Ctx.req

      // FIXME: Make UUID and Date mockable
      let requestID = UUID()
      let startTime = Date().timeIntervalSince1970
      // FIXME: Trying a single log entry instead of 1 req + 1 res log
      // This can cause some issues, like if the task never ends, we will never
      // know it started in the first place.
      // So I guess we gotta figure out how to cancel this on timeout and log that it timmed out.
      // Maybe we can just use a Task, but I will check later
      let res = await next()
      let endTime = Date().timeIntervalSince1970
      let timeDiff = formatSecondsToDisplay(endTime - startTime)

      logger.log(
        level: .info,
        """
        \(requestID) \
        \(res.status.code) \
        in \(timeDiff) \
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
