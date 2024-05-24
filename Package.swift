// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "swift-plumbing",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable(name: "plumb", targets: ["Plumb"]),
    .library("Plumbing"),
    .library("PlumbingHttp"),
    .library("PlumbingHttpRouter"),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-beta.5"),
    .package(url: "https://github.com/pointfreeco/swift-url-routing.git", from: "0.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-prelude.git", revision: "da5ead2"),
  ],
  targets: [
    .executableTarget(
      name: "Plumb",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .target(
      name: "Plumbing",
      dependencies: [
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tuple", package: "swift-prelude"),
      ]
    ),
    .target(
      name: "PlumbingHttp",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdCore", package: "hummingbird"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "NIOCore", package: "swift-nio"),
      ]
    ),
    .target(
      name: "PlumbingHttpRouter",
      dependencies: [
        "PlumbingHttp",
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "URLRouting", package: "swift-url-routing"),
      ]
    ),
  ]
)

extension Product {
  static func library(_ name: String) -> Product {
    .library(name: name, targets: [name])
  }
}
