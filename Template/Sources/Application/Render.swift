import Hummingbird
import Plumbing
import PlumbingHummingbird
import Router

func render(route: Route) -> AsyncResult<Response, Response> {
  switch route {
  case .home: return homeHandler()
  case .healthcheck: return healthcheckHandler()
  }
}

func homeHandler() -> AsyncResult<Response, Response> {
  return .success(
    .init(
      status: .ok,
      headers: [.contentType: "text/plain"],
      body: .init(byteBuffer: .init(string: "Hello World"))
    )
  )
}

func healthcheckHandler() -> AsyncResult<Response, Response> {
  return .success(.init(status: .ok))
}
