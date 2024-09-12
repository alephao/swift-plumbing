import Html

extension Node {
  public static func svg(
    url: String,
    iconId: String? = nil,
    class: String,
    width: Int,
    height: Int? = nil,
    ariaHidden: Bool = true
  ) -> Node {
    let fragment = iconId ?? "icon"
    return .svg(
      attributes: attrs(
        .class(`class`),
        .width(width),
        .height(height ?? width),
        ariaHidden ? .ariaHidden(.true) : nil
      ),
      unsafe: "<use xlink:href=\"\(url)#\(fragment)\"></use>"
    )
  }

  public static func svg(
    url: String,
    iconId: String? = nil,
    attributes: [Attribute<Tag.Svg>] = []
  ) -> Node {
    let fragment = iconId ?? "icon"
    return .svg(
      attributes: attributes,
      unsafe: "<use xlink:href=\"\(url)#\(fragment)\"></use>"
    )
  }
}
