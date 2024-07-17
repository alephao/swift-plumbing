import Hummingbird

extension Response {
  public static func redirect(
    to url: String,
    type: RedirectType,
    extraHeaders: HTTPFields = [:]
  ) -> Self {
    var response = Response.redirect(
      to: url,
      type: type
    )
    response.headers.append(contentsOf: extraHeaders)
    return response
  }

  public static func redirect(
    to url: String
  ) -> Self {
    .redirect(to: url, type: .normal, extraHeaders: [:])
  }
}
