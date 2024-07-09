import Hummingbird
import Logging
import Plumbing
import PlumbingHummingbird

public enum CacheRule {
  case noCache
  case immutable
  case custom(_ f: (MediaType) -> String)

  public func value(for mediaType: MediaType) -> String {
    switch self {
    case .noCache: return "no-cache"
    case .immutable: return "public, max-age=31536000, s-maxage=31536000, immutable"
    case .custom(let f): return f(mediaType)
    }
  }
}

public func publicAssetsMiddleware(
  localFileSystem: LocalFileSystem,
  logger: Logger,
  getFilePath: @escaping (String) -> String?,
  cache: CacheRule
) -> Middleware {
  { next in
    { req, ctx in
      guard
        req.method == .get,
        let assetPath = getFilePath(req.uri.path)
      else {
        return await next(req, ctx)
      }

      guard let fullPath = localFileSystem.getFileIdentifier(assetPath) else {
        return .init(status: .notFound)
      }

      let res = await AsyncResult<String, Response>.success(fullPath)
        .prepend(getFileAttributes(localFileSystem, logger: logger))
        .flatMap(loadFile(localFileSystem, logger: logger, cache: cache, ctx: ctx))
        .run()

      return res.either()
    }
  }
}

private func getFileAttributes(
  _ fs: LocalFileSystem,
  logger: Logger
) -> (String) -> AsyncResult<LocalFileSystem.FileAttributes, Response> {
  { path in
    .init {
      do {
        guard
          let attributes = try await fs.getAttributes(id: path),
          !attributes.isFolder
        else {
          return .failure(.init(status: .notFound))
        }
        return .success(attributes)
      } catch {
        logger.warning(
          "publicAssetsMiddleware: failed to LocalFileSystem.getAttributes: \(String(reflecting: error))"
        )
        return .failure(.init(status: .notFound))
      }
    }
  }
}

private func loadFile(
  _ fs: LocalFileSystem,
  logger: Logger,
  cache: CacheRule,
  ctx: PlumbingRequestContext
)
  -> (T2<LocalFileSystem.FileAttributes, String>)
  -> AsyncResult<Response, Response>
{
  { t in
    .init {
      let attributes = get1(t)
      let path = rest(t)
      do {
        let body = try await fs.loadFile(id: path, context: ctx)

        var headers: HTTPFields = [
          .contentLength: String(describing: attributes.size)
        ]

        if let extPointIndex = path.lastIndex(of: ".") {
          let extIndex = path.index(after: extPointIndex)
          let ext = String(path.suffix(from: extIndex))

          if ext == "webmanifest" {
            headers[.contentType] = "application/manifest+json"
            headers[.cacheControl] = cache.value(for: .textPlain)  // Any value, doens't matter
          } else if let contentType = MediaType.getMediaType(forExtension: ext) {
            headers[.contentType] = contentType.description
            headers[.cacheControl] = cache.value(for: contentType)
          }
        }

        let res = Response(
          status: .ok,
          headers: headers,
          body: body
        )
        return .success(res)
      } catch {
        logger.warning(
          "publicAssetsMiddleware: failed to LocalFileSystem.loadFile: \(String(reflecting: error))"
        )
        return .failure(.init(status: .notFound))
      }
    }
  }
}
