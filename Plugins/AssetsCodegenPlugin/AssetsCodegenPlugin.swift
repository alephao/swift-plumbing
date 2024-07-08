import PackagePlugin
import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

//private let defaultIgnoreFiles: Set<String> = [".DS_Store", ".gitkeep"]
//func getInputFiles(publicAssetsRootPath: String) -> [Path] {
//  let rootURL = URL(filePath: publicAssetsRootPath)
//  guard let inputFilesEnumerator = FileManager.default.enumerator(
//    at: rootURL,
//    includingPropertiesForKeys: [],
//    options: [],
//    errorHandler: nil
//  ) else {
//    return []
//  }
//
//  let inputFiles = inputFilesEnumerator
//    .compactMap({ element -> Path? in
//      guard
//        let url = element as? URL,
//        !url.hasDirectoryPath,
//        !defaultIgnoreFiles.contains(url.lastPathComponent)
//      else { return nil }
//      return Path(url.absoluteString)
//    })
//
//  return inputFiles
//}

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

//    let inputFiles = getInputFiles(publicAssetsRootPath: publicFilesPath.string)

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
//        environment: [:],
        inputFiles: [],
        outputFiles: [ outputFilePath ]
      )
    ]
  }
}
