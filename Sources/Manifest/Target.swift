import Foundation

public struct Target: Codable {
    public let name: String
    public let path: String?
    public let publicHeadersPath: String?
    public let dependencies: [String]
    public let exclude: [String]
    public let source: [String]
}

extension Manifest {
    
    /// An interface for the package's target declarations.
    var targets: Targets { return Targets(manifest: self) }
    
    /// Gets the target declaration with a given name
    ///
    /// - parameter name: The name of the target to fetch.
    ///
    /// - returns: Thr target with the name passed in.
    /// - throws: Any errors that occur when fetching the package's tarets.
    public func target(withName name: String)throws -> Target? {
        return try self.targets().filter({ $0.name == name }).first
    }
    
    
}

/// A wrapper for interacting with manifest target declarations.
public class Targets {
    
    private let manifest: Manifest
    
    public init(manifest: Manifest) {
        self.manifest = manifest
    }
    
    /// Gets the targets declared in the project's manifest.
    ///
    /// - warning: Not complete. Only gets target name and dependencies.
    ///
    /// - returns: The project's targets parsed into data structures.
    /// - throws: Errors that occur while fetching the manifest contents or create the regex for maching the targets.
    public func get()throws -> [Target] {
        let pattern = try NSRegularExpression(
            pattern: "\\.(testT|t)arget\\(name:\\s*\"(.*?)\",\\s*dependencies:\\s*(\\[.*?\\])\\)",
            options: []
        )
        let contents: String = try manifest.contents()
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
