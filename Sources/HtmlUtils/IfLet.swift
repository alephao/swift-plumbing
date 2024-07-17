import Html

extension Node {
  public static func iflet<T>(_ t: T?, _ f: (T) -> Node) -> Node {
    return t.map(f) ?? .fragment([])
  }
}

extension ChildOf {
  public static func iflet<T>(_ t: T?, _ f: (T) -> ChildOf) -> ChildOf {
    return t.map(f) ?? .fragment([])
  }
}
