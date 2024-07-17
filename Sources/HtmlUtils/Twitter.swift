import Html

public enum TwitterMeta {
  public enum Card: String {
    case summaryLargeImage = "summary_large_image"
  }
}

extension ChildOf where Element == Tag.Head {
  public static func twitter(
    title: String?,
    description: String?,
    card: TwitterMeta.Card?,
    image: String?
  ) -> ChildOf<Tag.Head> {
    .fragment([
      .iflet(title, { .meta(name: "twitter:title", content: $0) }),
      .iflet(description, { .meta(name: "twitter:description", content: $0) }),
      .iflet(card, { .meta(name: "twitter:card", content: $0.rawValue) }),
      .iflet(image, { .meta(name: "twitter:image", content: $0) }),
    ])
  }
}
