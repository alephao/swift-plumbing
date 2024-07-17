import Html
import Hummingbird

extension Response {
  public static func html(
    status: HTTPResponse.Status = .ok,
    extraHeaders: HTTPFields,
    node: Node
  ) -> Self {
    var headers: HTTPFields = [
      .contentType: "text/html"
    ]
    headers.append(contentsOf: extraHeaders)
    return Response(
      status: status,
      headers: headers,
      body: .init(byteBuffer: .init(string: render(node)))
    )
  }

  public static func html(
    status: HTTPResponse.Status = .ok,
    node: Node
  ) -> Self {
    return Response(
      status: status,
      headers: [.contentType: "text/html"],
      body: .init(byteBuffer: .init(string: render(node)))
    )
  }

  public static func html(
    node: Node
  ) -> Self {
    html(status: .ok, extraHeaders: [:], node: node)
  }
}
