import Html

extension Node {
  public static func svg(
    url: String,
    class: String,
    width: Int,
    height: Int? = nil
  ) -> Node {
    .svg(
      attributes: [.class(`class`), .width(width), .height(height ?? width)],
      unsafe: "<use xlink:href=\"\(url)#icon\"></use>"
    )
  }
}
