// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "swift-plumbing",
  products: [
    .library(name: "Plumbing", targets: ["Plumbing"]),
  ],
  targets: [
    .target(name: "Plumbing"),
  ]
)
