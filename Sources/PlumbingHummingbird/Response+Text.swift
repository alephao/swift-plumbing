import Hummingbird

extension Response {
  public static func text(_ txt: String) -> Self {
    return .init(
      status: .ok,
      headers: [.contentType: "text/plain"],
      body: .init(byteBuffer: .init(string: txt))
    )
  }
}
