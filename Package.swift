// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "swift-plumbing",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .executable("plumb"),
    .plugin("AssetsCodegenPlugin"),
    .library("Plumbing"),
    .library("PlumbingHttp"),
    .library("PlumbingHummingbird"),
    // Middlewares
    .library("LoggerMiddleware"),
    .library("PublicAssetsMiddleware"),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0-rc.2"),
    .package(url: "https://github.com/alephao/swift-prelude.git", from: "0.7.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.0.0"),
    .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
  ],
  targets: [
    .executableTarget(
      name: "plumb",
      dependencies: [
        "PlumbAssetsCodegen",
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Crypto", package: "swift-crypto"),
      ]
    ),
    .target(
      name: "PlumbAssetsCodegen",
      dependencies: [
        .product(name: "Crypto", package: "swift-crypto")
      ]
    ),
    .plugin(
      name: "AssetsCodegenPlugin",
      capability: .buildTool(),
      dependencies: [
        "plumb"
      ]
    ),
    .target(
      name: "Plumbing",
      dependencies: [
        .product(name: "Prelude", package: "swift-prelude"),
        .product(name: "Tuple", package: "swift-prelude"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "PlumbingHttp",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdCore", package: "hummingbird"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
      ]
    ),
    .target(
      name: "PlumbingHummingbird",
      dependencies: [
        .product(name: "Hummingbird", package: "hummingbird"),
        .product(name: "HummingbirdCore", package: "hummingbird"),
        .product(name: "Logging", package: "swift-log"),
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "LoggerMiddleware",
      dependencies: [
        "PlumbingHummingbird",
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "PublicAssetsMiddleware",
      dependencies: [
        "Plumbing",
        "PlumbingHummingbird",
        .product(name: "Logging", package: "swift-log"),
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
  ]
)

extension Product {
  static func executable(_ name: String) -> Product {
    .executable(name: name, targets: [name])
  }

  static func library(_ name: String) -> Product {
    .library(name: name, targets: [name])
  }

  static func plugin(_ name: String) -> Product {
    .plugin(name: name, targets: [name])
  }
}
