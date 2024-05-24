import Hummingbird
import Plumbing

public func publicAssetsMiddleware(
  localFileSystem: LocalFileSystem,
  getFilePath: @escaping (String) -> String?
) -> PlumbingHTTPMiddleware {
  { next in
    {
      guard
        Ctx.req.method == .get,
        let assetPath = getFilePath(Ctx.req.uri.path)
      else {
        return await next()
      }

      let fullPath = localFileSystem.getFullPath(assetPath)

      let res = await AsyncResult.success(fullPath)
        .prepend(getFileAttributes(localFileSystem))
        .flatMap(loadFile(localFileSystem))
        .run()

      return res.either()
    }
  }
}

private func getFileAttributes(
  _ fs: LocalFileSystem
) -> (String) -> AsyncResult<LocalFileSystem.FileAttributes, Response> {
  { path in
    .init {
      do {
        guard
          let attributes = try await fs.getAttributes(path: path),
          !attributes.isFolder
        else {
          return .failure(.init(status: .notFound))
        }
        return .success(attributes)
      } catch {
        Ctx.logger.warning(
          "publicAssetsMiddleware: failed to LocalFileSystem.getAttributes: \(String(reflecting: error))"
        )
        return .failure(.init(status: .notFound))
      }
    }
  }
}

private func loadFile(_ fs: LocalFileSystem)
  -> (T2<LocalFileSystem.FileAttributes, String>)
  -> AsyncResult<Response, Response>
{
  { t in
    .init {
      let attributes = get1(t)
      let path = rest(t)
      do {
        let body = try await fs.loadFile(path: path, context: Ctx.ctx)

        var headers: HTTPFields = [
          .contentLength: String(describing: attributes.size)
        ]

        if let extPointIndex = path.lastIndex(of: ".") {
          let extIndex = path.index(after: extPointIndex)
          let ext = String(path.suffix(from: extIndex))
          if let contentType = MediaType.getMediaType(forExtension: ext) {
            headers[.contentType] = contentType.description
            // TODO: Maybe make this configurable
            headers[.cacheControl] = cacheControl(for: contentType)
          }
        }

        let res = Response(
          status: .ok,
          headers: headers,
          body: body
        )
        return .success(res)
      } catch {
        Ctx.logger.warning(
          "publicAssetsMiddleware: failed to LocalFileSystem.loadFile: \(String(reflecting: error))"
        )
        return .failure(.init(status: .notFound))
      }
    }
  }
}

// TODO: Maybe make this configurable
private func cacheControl(for mediaType: MediaType) -> String? {
  // Ideally we add checksums to every file
  // Not sure about:
  // - site.webmanifest
  // - robots.txt
  // - .well-known stuff
  // - sitemap.xml

  #if DEBUG
    return "no-cache"
  #else
    switch mediaType {
    case .imageIco: return "max-age=86400"
    case .textCss, .textJavascript: return "max-age=31536000, immutable"
    default: break
    }

    switch mediaType.type {
    case .image, .video, .font: return "max-age=31536000, immutable"
    default: return nil
    }
  #endif
}
