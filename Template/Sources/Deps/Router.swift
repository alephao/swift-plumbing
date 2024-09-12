import Dependencies
import Router

// MARK: Router

extension Router: DependencyKey {
  public static let liveValue = {
    @Dependency(\.envVars.baseUrl) var baseUrl
    return Router(
      baseURL: baseUrl,
      rootRouter: RootRouter()
    )
  }()
}

// MARK: Route

extension Route: DependencyKey {
  public static let liveValue: Route = .home
}
