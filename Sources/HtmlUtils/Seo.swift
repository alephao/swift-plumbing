import Html

extension ChildOf where Element == Tag.Head {
  public static func seo(
    siteName: String,
    title: String,
    description: String?,
    canonicalUrl: String,
    image: String,
    ogType: OpenGraphMeta.OGType = .website,
    twitterCard: TwitterMeta.Card = .summaryLargeImage
  ) -> ChildOf<Tag.Head> {
    .fragment([
      .title(title),
      .iflet(description, { .meta(description: $0) }),
      .link(attributes: [
        .rel(.init(rawValue: "canonical")), .href(canonicalUrl),
      ]),
      .openGraph(
        title: title,
        description: description,
        url: canonicalUrl,
        type: ogType,
        image: image,
        siteName: siteName
      ),
      .twitter(
        title: title,
        description: description,
        card: twitterCard,
        image: image
      ),
    ])
  }
}
