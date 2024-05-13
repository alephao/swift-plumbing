import ArgumentParser

// - Generate swift code referencing static assets
// - Map static assets with checksummed names to the original file name
struct AssetsCommand: ParsableCommand {
  static var configuration: CommandConfiguration = CommandConfiguration(commandName: "assets")

  init() {}

  func run() throws {
    print("Init")
  }
}
