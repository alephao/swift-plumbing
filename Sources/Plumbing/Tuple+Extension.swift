import Tuple

public func prepend<A, B>(_ a: A, _ b: B) -> T2<B, A> { b .*. a }
public func discardLeft<A, B>(_ t: Tuple<A, B>) -> B { t.second }
public func discardRight<A, B>(_ t: Tuple<A, B>) -> A { t.first }
