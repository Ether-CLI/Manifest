import Foundation

/// Represents a target declaration in a project's manifest.
public class Target {
    
    /// Wheather the target is for testing or not.
    public let isTest: Bool
    
    /// The name of the target.
    public let name: String
    
    /// The path to the target from the root of the project.
    public let path: String?
    
    /// The path to the directory containing public headers of a C target. _Only valid for C family library targets._
    public let publicHeadersPath: String?
    
    /// The targets in the package or one of the packages dependencies that the declared target can access through imports.
    public let dependencies: [String]
    
    /// The files and directories that are excluded from being picked up as sources.
    public let exclude: [String]
    
    /// The source files to include in the target. If it is empty, then any valid source file is included.
    public let source: [String]
    
    /// The `Targets` instance that the target originates from.
    public let parent: Targets
    
    ///
    public init(isTest: Bool, name: String, path: String?, publicHeadersPath: String?, dependencies: [String], exclude: [String], source: [String], parent: Targets) {
        self.isTest = isTest
        self.name = name
        self.path = path
        self.publicHeadersPath = publicHeadersPath
        self.dependencies = dependencies
        self.exclude = exclude
        self.source = source
        self.parent = parent
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
