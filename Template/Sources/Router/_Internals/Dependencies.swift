import Dependencies
import Logging

// MARK: Router

extension Router: TestDependencyKey {
  public static let testValue = Router(
    baseURL: .init(string: "https://www.example.com")!,
    rootRouter: RootRouter()
  )
}

extension DependencyValues {
  public var router: Router {
    get { self[Router.self] }
    set { self[Router.self] = newValue }
  }
}

// MARK: Route

extension Route: TestDependencyKey {
  public static var testValue: Route = .home
}

extension DependencyValues {
  public var route: Route {
    get { self[Route.self] }
    set { self[Route.self] = newValue }
  }
}
