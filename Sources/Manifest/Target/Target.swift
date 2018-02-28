/// Represents a target declaration in a project's manifest.
public struct Target: Codable {
    
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
}
