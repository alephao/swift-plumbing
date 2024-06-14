#if canImport(Html)
import Dependencies
import Html

extension Attribute where Element == Tag.Form {
  public static func action(route: Route) -> Attribute {
    @Dependency(\.router) var router
    return action(router.path(for: route))
  }
}

extension Attribute where Element: HasHref {
  public static func href(route: Route) -> Attribute {
    @Dependency(\.router) var router
    return href(router.path(for: route))
  }
}
#endif
