import Foundation

extension FileManager {
  func ls(
    _ path: String,
    ignoring ignorePredicate: (String) -> Bool = { _ in false },
    recursive: Bool
  ) throws -> [FileOrDir] {
    return try self.contentsOfDirectory(atPath: path)
      .filter({ !ignorePredicate($0) })
      .map({
        return isDir(path + "/" + $0)
          ? FileOrDir.dir(
            $0,
            subpaths: recursive
              ? try ls(path + "/" + $0, ignoring: ignorePredicate, recursive: true)
              : []
          )
          : FileOrDir.file($0)
      })
  }

  func isDir(_ path: String) -> Bool {
    var isDirectory = ObjCBool(false)
    guard self.fileExists(atPath: path, isDirectory: &isDirectory) else {
      fatalError("dir/file does not exist at path: '\(path)'")
    }
    return isDirectory.boolValue
  }
}
