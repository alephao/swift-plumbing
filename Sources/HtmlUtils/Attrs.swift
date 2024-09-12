import Html

public func attrs<Tag>(_ attributes: Attribute<Tag>...) -> [Attribute<Tag>] {
  return attributes
}

public func attrs<Tag>(_ attributes: Attribute<Tag>?...) -> [Attribute<Tag>] {
  return attributes.compactMap({ $0 })
}
