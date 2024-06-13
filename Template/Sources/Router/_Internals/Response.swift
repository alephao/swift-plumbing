import Dependencies
import Hummingbird
import PlumbingHummingbird

extension Response {
  public static func redirect(
    route: Route,
    type: RedirectType,
    extraHeaders: HTTPFields = [:]
  ) -> Self {
    @Dependency(\.router) var router
    var response = Response.redirect(
      to: router.path(for: route),
      type: type
    )
    response.headers.append(contentsOf: extraHeaders)
    return response
  }

  public static func redirect(
    route: Route
  ) -> Self {
    .redirect(route: route, type: .normal, extraHeaders: [:])
  }
}
