import Html

public enum OpenGraphMeta {
  public enum OGType: String {
    case website = "website"
  }
}

extension ChildOf where Element == Tag.Head {
  public static func openGraph(
    title: String?,
    description: String?,
    url: String,
    type: OpenGraphMeta.OGType?,
    image: String?,
    siteName: String?
  ) -> ChildOf<Tag.Head> {
    .fragment([
      .iflet(title, { .meta(property: "og:title", content: $0) }),
      .iflet(description, { .meta(property: "og:description", content: $0) }),
      .iflet(url, { .meta(property: "og:url", content: $0) }),
      .iflet(type, { .meta(property: "og:type", content: $0.rawValue) }),
      .iflet(image, { .meta(property: "og:image", content: $0) }),
      .iflet(siteName, { .meta(property: "og:site_name", content: $0) }),
    ])
  }
}
