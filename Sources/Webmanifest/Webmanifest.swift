import Foundation
import Plumbing
import PlumbingHummingbird

public func webmanifestHandler(
  _ webManifest: WebManifest,
  cache: Bool = false
) -> AsyncResult<Response, Response> {
  do {
    var buffer = ByteBuffer()
    try JSONEncoder().encode(webManifest, into: &buffer)
    var headers: HTTPFields = [
      .contentType: "application/manifest+json"
    ]
    if cache {
      headers[.cacheControl] = "public, max-age=31536000, s-maxage=31536000, immutable"
    }
    return .success(
      Response(
        status: .ok,
        headers: headers,
        body: .init(byteBuffer: buffer)
      )
    )
  } catch {
    return .failure(Response(status: .internalServerError))
  }
}

public struct WebManifest: Encodable {
  public let backgroundColor: String
  public let display: String
  public let icons: [Icon]
  public let name: String
  public let shortName: String
  public let themeColor: String

  public init(
    backgroundColor: String,
    display: String,
    icons: [WebManifest.Icon],
    name: String,
    shortName: String,
    themeColor: String
  ) {
    self.backgroundColor = backgroundColor
    self.display = display
    self.icons = icons
    self.name = name
    self.shortName = shortName
    self.themeColor = themeColor
  }

  public struct Icon: Encodable {
    public let src: String
    public let sizes: String
    public let type: String

    public init(
      src: String,
      sizes: String,
      type: String
    ) {
      self.src = src
      self.sizes = sizes
      self.type = type
    }
  }

  public enum CodingKeys: String, CodingKey {
    case backgroundColor = "background_color"
    case display
    case icons
    case name
    case shortName = "short_name"
    case themeColor = "theme_color"
  }
}
