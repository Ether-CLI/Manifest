import Foundation
import Utilities

extension Manifest {
    
    /// An interface for the package's target declarations.
    var targets: Targets { return Targets(manifest: self) }
}

/// A wrapper for interacting with manifest target declarations.
public class Targets {
    
    private let manifest: Manifest
    
    public init(manifest: Manifest) {
        self.manifest = manifest
    }
    
    /// Gets the targets declared in the project's manifest.
    ///
    /// - returns: The project's targets parsed into data structures.
    /// - throws: Errors that occur while fetching the manifest contents or create the regex for maching the targets.
    @available(OSX 10.13, *)
    public func all()throws -> [Target] {
        let pattern = try NSRegularExpression(
            pattern: "\\.(testT|t)arget\\(name:\\s*\"(.*?)\",\\s*dependencies:\\s*(\\[.*?\\])(?:,\\s*path:\\s*\"(.*?)\")?(?:,\\s*exclude:\\s*(\\[(?:\\s*\".*?\",?\\s*)*\\]))?(?:,\\s*sources:\\s*(\\[(?:\\s*\".*?\",?\\s*)*\\]))?(?:,\\s*publicHeadersPath:\\s*\"(.*?)\")?\\)",
            options: []
        )
        let contents: String = try self.manifest.contents()
        
        return try pattern.matches(in: contents, range: contents.range).map { (result) -> Target in
            guard let name = contents.substring(at: result.range(at: 2)) else {
                throw ManifestError(identifier: "nameNotFound", reason: "A target must have a name argument")
            }
            
            let isTest = contents.substring(at: result.range(at: 1)) == "testT"
            let dependencies = contents.parseArray(at: result.range(at: 3))
            let path = contents.substring(at: result.range(at: 4))
            let exclude = contents.parseArray(at: result.range(at: 5))
            let sources = contents.parseArray(at: result.range(at: 6))
            let headers = contents.substring(at: result.range(at: 7))
            
            return Target(isTest: isTest, name: name, path: path, publicHeadersPath: headers, dependencies: dependencies, exclude: exclude, source: sources)
        }
    }
    
    /// Gets the target declaration with a given name
    ///
    /// - parameter name: The name of the target to fetch.
    ///
    /// - returns: Thr target with the name passed in.
    /// - throws: Any errors that occur when fetching the package's tarets.
    @available(OSX 10.13, *)
    public func get(withName name: String)throws -> Target? {
        return try self.all().filter({ $0.name == name }).first
    }
    
    /// Deletes a target from a project's manifest.
    ///
    /// - Parameter name: The name of the target to delete.
    /// - Throws: Error's that occur when create the RegEx for matching the target.
    public func delete(withName name: String)throws {
        let target = try NSRegularExpression(
            pattern: "(?:\\n*\\s*)?\\.(?:testT|t)arget\\(\\s*name:\\s*\"\(name)\".*?\\),?",
            options: []
        )
        let dependencies = try NSRegularExpression(
            pattern: "(\\.(?:executable|library)\\(\\s*name:\\s*\".*?\"\\s*,\\s*(?:type:\\s*\\.(?:static|dynamic)\\s*,\\s*)?targets:\\s*\\[)((.*?),\\s*\"\(name)\"|\"\(name)\"\\s*,\\s*)(.*?\\]\\))",
            options: []
        )
        
        let contents: NSMutableString = try manifest.contents()
        
        target.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "")
        dependencies.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$1$3$4")
        try self.manifest.write(with: contents)
    }
}
