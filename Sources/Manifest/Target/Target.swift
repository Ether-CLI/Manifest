import Foundation
import Utilities

/// Represents a target declaration in a project's manifest.
public class Target: CustomStringConvertible {
    
    /// Wheather the target is for testing or not.
    public let isTest: Bool
    
    /// The name of the target.
    public let name: String
    
    /// The path to the target from the root of the project.
    public var path: String?
    
    /// The path to the directory containing public headers of a C target. _Only valid for C family library targets._
    public var publicHeadersPath: String?
    
    /// The targets in the package or one of the packages dependencies that the declared target can access through imports.
    public var dependencies: [String]
    
    /// The files and directories that are excluded from being picked up as sources.
    public var exclude: [String]
    
    /// The source files to include in the target. If it is empty, then any valid source file is included.
    public var source: [String]
    
    /// The `Targets` instance that the target originates from.
    public let manifest: Manifest
    
    /// The raw string representation of the target's declaration in the manifest.
    public let raw: String
    
    /// Creates a `Target` with a RegEx match from a `String`.
    ///
    /// - Parameters:
    ///   - match: The RegEx match for the target.
    ///   - contents: The `String` that the match was fetched from.
    ///   - parent: The `Targets` model that is creating the `Target`.
    /// - Throws: `nameNotFound` if the target has no name and `.targetNotFound` if no target is found in the contents with the match passed in.
    public init(match: NSTextCheckingResult, in contents: String, with manifest: Manifest)throws {
        guard let name = contents.substring(at: match.range(at: 2)) else {
            throw ManifestError(identifier: "nameNotFound", reason: "A target must have a name argument")
        }
        guard let raw = contents.substring(at: match.range(at: 0)) else {
            throw ManifestError(identifier: "targetNotFound", reason: "No target was found with the given match")
        }
        
        self.name = name
        self.raw = raw
        self.isTest = contents.substring(at: match.range(at: 1)) == "testT"
        self.dependencies = contents.parseArray(at: match.range(at: 3))
        self.path = contents.substring(at: match.range(at: 4))
        self.exclude = contents.parseArray(at: match.range(at: 5))
        self.source = contents.parseArray(at: match.range(at: 6))
        self.publicHeadersPath = contents.substring(at: match.range(at: 7))
        self.manifest = manifest
    }
    
    ///
    public init(isTest: Bool, name: String, path: String?, publicHeadersPath: String?, dependencies: [String], exclude: [String], source: [String], manifest: Manifest? = nil) {
        self.isTest = isTest
        self.name = name
        self.path = path
        self.publicHeadersPath = publicHeadersPath
        self.dependencies = dependencies
        self.exclude = exclude
        self.source = source
        self.manifest = manifest ?? Manifest.current
        self.raw = (isTest ? ".testTarget" : ".target") +
            "(name: \"\(name)\", dependencies: \(dependencies.description)" +
            (path == nil ? "" : ", path: \"\(path!)\"") +
            (exclude == [] ? "" : ", exclude: \(exclude.description)") +
            (source == [] ? "" : ", sources: \(source.description)") +
            (publicHeadersPath == nil ? "" : ", publicHeadersPath: \"\(publicHeadersPath!)\"") +
            ")"
    }
    
    /// The target formatted for the manifest.
    public var description: String {
        return (self.isTest ? ".testTarget" : ".target") +
        "(name: \"\(self.name)\", dependencies: \(self.dependencies.description)" +
        (self.path == nil ? "" : ", path: \"\(self.path!)\"") +
        (self.exclude == [] ? "" : ", exclude: \(self.exclude.description)") +
        (self.source == [] ? "" : ", sources: \(self.source.description)") +
        (self.publicHeadersPath == nil ? "" : ", publicHeadersPath: \"\(self.publicHeadersPath!)\"") +
        ")"
    }
}
