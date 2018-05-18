import Foundation

/// The version syntax optionas that can be used
/// when defining a dependency instance.
public enum DependencyVersionType: CustomStringConvertible {
    
    /// `from: "1.0.0"`
    case from(String)
    
    /// `.upToNextMajor(from: "1.5.8")`
    case upToNextMajor(String)
    
    /// `.exact("1.5.8")`
    case exact(String)
    
    /// `"1.2.3"..<"1.2.6"`.
    /// Instead of just storing version numbers in this case,
    /// you need to include the whole range.
    case range(String)
    
    /// `.branch("develop")`
    case branch(String)
    
    /// `.revision("e74b07278b926c9ec6f9643455ea00d1ce04a021")`
    case revision(String)
    
    /// Creates a version instance from a version instance from a manifest's dependency.
    ///
    /// - parameter version: The version instance. See the docs for the cases for examples.
    public init(from version: String)throws {
        let index = version.index(version.startIndex, offsetBy: 2)
        let id = String(version[index])
        
        switch id {
            
        // Case for `from`
        case "o":
            let pattern = try NSRegularExpression(pattern: "from\\s*:\\s*\"(.*?)\"", options: [])
            self = try .from(DependencyVersionType.value(in: version, with: pattern))
            
        // Case for `.upToNextMajor`
        case "p":
            let pattern = try NSRegularExpression(pattern: "\\.upToNextMajor\\(from:\\s*\"(.*?)\"\\s*\\)", options: [])
            self = try .upToNextMajor(DependencyVersionType.value(in: version, with: pattern))
            
        // Case for `.exact`
        case "x":
            let pattern = try NSRegularExpression(pattern: "\\.exact\\(\"(.*?)\"\\)", options: [])
            self = try .exact(DependencyVersionType.value(in: version, with: pattern))
            
        // Case for `.branch`
        case "r":
            let pattern = try NSRegularExpression(pattern: "\\.branch\\(\"(.*?)\"\\)", options: [])
            self = try .branch(DependencyVersionType.value(in: version, with: pattern))
            
        // Case for `.revision`
        case "e":
            let pattern = try NSRegularExpression(pattern: "\\.revision\\(\"(.*?)\"\\)", options: [])
            self = try .revision(DependencyVersionType.value(in: version, with: pattern))
            
        // Case for `...` (range)
        default:
            let pattern = try NSRegularExpression(pattern: "(.*)", options: [])
            self = try .range(DependencyVersionType.value(in: version, with: pattern))
        }
    }
    
    /// The version formatted for the manifest.
    public var description: String {
        switch self {
        case let .from(version): return "from: \"\(version)\""
        case let .upToNextMajor(version): return ".upToNextMajor(from: \"\(version)\")"
        case let .exact(version): return ".exact(\"\(version)\")"
        case let .branch(branch): return ".branch(\"\(branch)\")"
        case let .revision(revision): return ".revision(\"\(revision)\")"
        case let .range(range): return range
        }
    }
    
    static func value(in string: String, with pattern: NSRegularExpression, at group: Int = 1)throws -> String {
        guard let range = pattern.matches(in: string, options: [], range: string.range).first?.range(at: 1) else {
            throw ManifestError(identifier: "noRangeForGroup", reason: "No subsring range exists with the given capture group.")
        }
        guard let value = string.substring(at: range) else {
            throw ManifestError(identifier: "noSubstringAtRange", reason: "No substring was found with the given range '\(range.description)'")
        }
        return value
    }
}
