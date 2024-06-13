enum FileOrDir {
  case file(_ fileName: String)
  indirect case dir(_ dirName: String, subpaths: [FileOrDir])

  func flatten() -> [String] {
    switch self {
    case .file(let fileName): return [fileName]
    case .dir(let dirName, let subpaths):
      return subpaths.flatMap({ subpath in
        subpath.flatten().map({ n in dirName + "/" + n })
      })
    }
  }

  func flattenComponents() -> [[String]] {
    switch self {
    case .file(let fileName): return [[fileName]]
    case .dir(let dirName, let subpaths):
      return subpaths.flatMap({ subpath in
        subpath.flattenComponents().map({ n in [dirName] + n })
      })
    }
  }
}
