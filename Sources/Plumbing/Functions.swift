public func id<A>(_ a: A) -> A { a }

public func const<Value, A>(_ value: Value) -> (A) -> Value { { _ in value } }
public func const<Value, A, B>(_ value: Value) -> (A, B) -> Value { { _, _ in value } }
public func const<Value, A, B, C>(_ value: Value) -> (A, B, C) -> Value { { _, _, _ in value } }
public func const<Value, A, B, C, D>(_ value: Value) -> (A, B, C, D) -> Value { { _, _, _, _ in value } }

public func discardLeft<A, B>(_ a: A, _ b: B) -> B { b }
public func discardRight<A, B>(_ a: A, _ b: B) -> A { a }
