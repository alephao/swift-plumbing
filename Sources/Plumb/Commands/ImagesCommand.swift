import ArgumentParser

// - Generate Webp Images from PNG and JPG
// - Generate code for html Picture with @1x @2x @3x etc
struct ImagesCommand: ParsableCommand {
  static var configuration: CommandConfiguration = CommandConfiguration(commandName: "images")

  init() {}

  func run() throws {
    // webp - use cwebp
    // - cwebp /png/* -> /webp/*
    // - cwebp /jpg/* -> /webp/*
    // pic
    // - read png files
    // - generate

    print("Init")
  }
}
