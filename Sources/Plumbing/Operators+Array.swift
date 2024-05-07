public func map<A, B>(_ transform: @escaping (A) -> B) -> (Array<A>) -> Array<B> {
  { a in a.map(transform) }
}

public func flatMap<A, B>(_ transform: @escaping (A) -> Array<B>) -> (Array<A>) -> Array<B> {
  { a in a.flatMap(transform) }
}

public func >>= <A, B>(_ a: Array<A>, _ transform: @escaping (A) -> Array<B>) -> Array<B> {
  a.flatMap(transform)
}

public func >=> <A, B, C>(_ f: @escaping (A) -> Array<B>, _ g: @escaping (B) -> Array<C>) -> (A) -> Array<C> {
  f >>> flatMap(g)
}
