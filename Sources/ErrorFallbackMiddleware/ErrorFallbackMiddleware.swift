import PlumbingHummingbird

public func errorFallbackMiddleware(
  clientErrorHandler: ((Request, PlumbingRequestContext, Response) -> Response)?,
  serverErrorHandler: ((Request, PlumbingRequestContext, Response) -> Response)?
) -> Middleware {
  { next in
    { req, ctx in
      let res = await next(req, ctx)
      switch res.status.code {
      case 400...499:
        guard
          (res.body.contentLength ?? 0) == 0,
          let clientErrorHandler
        else { return res }
        return clientErrorHandler(req, ctx, res)

      case 500...599:
        guard
          (res.body.contentLength ?? 0) == 0,
          let serverErrorHandler
        else { return res }
        return serverErrorHandler(req, ctx, res)

      default:
        return res
      }
    }
  }
}
