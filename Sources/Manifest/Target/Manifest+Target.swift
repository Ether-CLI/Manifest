import Foundation
import Utilities

extension Manifest {
    
    /// An interface for the package's target declarations.
    var targets: Targets { return Targets(manifest: self) }
}

/// A wrapper for interacting with manifest target declarations.
public class Targets {
    
    internal let manifest: Manifest
    
    /// Creates an interface to interact with a manifest's targets.
    ///
    /// - parameter manifest: The manifest to access the targets from.
    public init(manifest: Manifest) {
        self.manifest = manifest
    }
    
    /// Gets the targets declared in the project's manifest.
    ///
    /// - returns: The project's targets parsed into data structures.
    /// - throws: Errors that occur while fetching the manifest contents or create the regex for maching the targets.
    public func all()throws -> [Target] {
        let pattern = try NSRegularExpression(
            pattern: "\\.(testT|t)arget\\(name:\\s*\"(.*?)\",\\s*dependencies:\\s*(\\[.*?\\])(?:,\\s*path:\\s*\"(.*?)\")?(?:,\\s*exclude:\\s*(\\[(?:\\s*\".*?\",?\\s*)*\\]))?(?:,\\s*sources:\\s*(\\[(?:\\s*\".*?\",?\\s*)*\\]))?(?:,\\s*publicHeadersPath:\\s*\"(.*?)\")?\\)",
            options: []
        )
        let contents: String = try self.manifest.contents()
        
        return try pattern.matches(in: contents, range: contents.range).map { (result) -> Target in
            return try Target(match: result, in: contents, with: self.manifest)
        }
    }
    
    /// Gets the target declaration with a given name
    ///
    /// - parameter name: The name of the target to fetch.
    ///
    /// - returns: Thr target with the name passed in.
    /// - throws: Any errors that occur when fetching the package's tarets.
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

    /// Adds a new target to the manifet's `targets` declaration.
    ///
    /// - Parameters:
    ///   - name: The name fo the new target.
    ///   - path: The path to the target's source from the project's root.
    ///   - headersPath: The path to the directory containing public headers of a C target. _Only valid for C family library targets._
    ///   - dependencies: The target's that the target can access through imports.
    ///   - exclude: Directories and source files to not include in the target's source.
    ///   - sources: Directories and source files to include in the target's source.
    ///   - isTest: Wheather or not the target is for testing.
    /// - Throws: Errors from reading or writing the manifest or creating the RegEx patterns to find the position to place the new target.
    public func create(
        withName name: String,
        path: String? = nil,
        headersPath: String? = nil,
        dependencies: [String] = [],
        exclude: [String] = [],
        sources: [String] = [],
        isTest: Bool = false
    )throws {
        let target = Target(isTest: isTest, name: name, path: path, publicHeadersPath: headersPath, dependencies: dependencies, exclude: exclude, source: sources, manifest: self.manifest)
        let contents: NSMutableString = try manifest.contents()
        let pattern: NSRegularExpression
        
        if isTest {
            if try NSRegularExpression(pattern: "(\\.(?:testT|t)arget\\(.*?\\),|],\\s*targets\\s*:\\s*\\[)(?=\\s*\\])", options: []).matches(
                in: String(contents),
                options: [],
                range: contents.range
            ).count > 0 {
                pattern = try NSRegularExpression(pattern: "(\\.(?:testT|t)arget\\(.*?\\),|],\\s*targets\\s*:\\s*\\[)(?=\\s*\\])", options: [])
                pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$1\n\(String(repeating: " ", count: 8))\(target.description)")
            } else {
                pattern = try NSRegularExpression(pattern: "(\\.(?:testT|t)arget\\(.*?\\)|],\\s*targets\\s*:\\s*\\[)(?=\\s*\\])", options: [])
                pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$1,\n\(String(repeating: " ", count: 8))\(target.description)")
            }
        } else {
            pattern = try NSRegularExpression(pattern: "(],\\s*targets\\s*:\\s*\\[)", options: [])
            pattern.replaceMatches(in: contents, options: [], range: contents.range, withTemplate: "$1\n\(String(repeating: " ", count: 8))\(target.description),")
        }
        
        try manifest.write(with: contents)
    }
}
