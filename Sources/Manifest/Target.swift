import Foundation

struct Target: Codable {
    let name: String
    let path: String?
    let publicHeadersPath: String?
    let dependencies: [String]
    let exclude: [String]
    let source: [String]
}

extension Manifest {
    
    /// Gets the targets declared in the project's manifest.
    ///
    /// - warning: Not complete. Only gets target name and dependencies.
    ///
    /// - returns: The project's targets parsed into data structures.
    /// - throws: Errors that occur while fetching the manifest contents or create the regex for maching the targets.
    func targets()throws -> [Target] {
        let pattern = try NSRegularExpression(
            pattern: "\\.(testT|t)arget\\(name:\\s*\"(.*?)\",\\s*dependencies:\\s*(\\[.*?\\])\\)",
            options: []
        )
        let contents: String = try self.contents()
        let string: NSString = NSString(string: contents)
        
        return pattern.matches(in: contents, range: NSRange(contents.startIndex..., in: contents)).map { (result) -> Target in
            let nameRange = result.range(at: 2)
            let dependenciesRange = result.range(at: 3)
            
            let name = string.substring(with: nameRange)
            let dependenciesString: String = String(string.substring(with: dependenciesRange).dropFirst().dropLast())
            let dependencies = dependenciesString.split(separator: ",").map({ (dep) in
                return String(dep.trimmingCharacters(in: .whitespacesAndNewlines).dropLast().dropFirst())
            })
            
            return Target(name: name, path: nil, publicHeadersPath: nil, dependencies: dependencies, exclude: [], source: [])
        }
    }
}
