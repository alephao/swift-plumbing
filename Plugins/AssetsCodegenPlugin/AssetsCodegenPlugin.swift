import PackagePlugin
import Foundation

@main struct AssetsCodegenPlugin {}

extension AssetsCodegenPlugin: BuildToolPlugin {
  func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
    guard target is SwiftSourceModuleTarget else { return [] }

    let checksum = ProcessInfo.processInfo.environment["CONFIGURATION"] != "Debug"

    // Prepare plumb to run
    // Get `plumb` executable
    let plumb = try context.tool(named: "plumb")
    // Get the `public` folder (input for the assets generation)
    let publicFilesPath = context.package.directory.appending(["public"])
    // Get the output directory
    let outputDir = context.pluginWorkDirectory.appending(["Generated"])
    let outputFilePath = outputDir.appending(["PublicFiles.gen.swift"])
    // Create the directory where the file will be generated
    try FileManager.default.createDirectory(
      atPath: outputDir.string,
      withIntermediateDirectories: true
    )
    // Arguments to pass to `plumb`
    var args: [String] = [
      "assets",
      "--path",
      publicFilesPath.string,
      "--out",
      outputFilePath.string,
    ]

    if (checksum) {
      args.append("--checksum")
    }

    return [
      .buildCommand(
        displayName: """
        [plumb] Running Assets Codegen
        inputDir: \(publicFilesPath.string)
        outputDir: \(outputDir.string)
        plumb \(args.joined(separator: " "))
        """,
        executable: plumb.path,
        arguments: args,
        environment: [:],
        inputFiles: [ publicFilesPath ],
        outputFiles: [ outputFilePath ]
      )
    ]
  }
}