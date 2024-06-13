import Dependencies
import Router

// MARK: Router

extension Router: DependencyKey {
  public static let liveValue = Router(
    baseURL: .init(string: "https://www.example.com")!,
    rootRouter: RootRouter()
  )
}

// MARK: Route

extension Route: DependencyKey {
  public static let liveValue: Route = .home
}
