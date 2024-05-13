import ArgumentParser

struct InitCommand: ParsableCommand {
  static var configuration: CommandConfiguration = CommandConfiguration(commandName: "init")

  init() {}

  func run() throws {
    // Get init config by prompting user
    // Copy necessary files from resources depending on user inputs
    // Replace copied files placeholders with user inputs
    print("Init")
  }
}
