import Foundation
import Utilities

extension Manifest {
    
    /// Gets the targets declared in the project's manifest.
    ///
    /// - returns: The project's targets parsed into data structures.
    /// - throws: Errors that occur while fetching the manifest contents or create the regex for maching the targets.
    public func targets()throws -> [Target] {
        let pattern = try NSRegularExpression(
            pattern: "\\.(testT|t)arget\\(name:\\s*\"(.*?)\",\\s*dependencies:\\s*(\\[.*?\\])(?:,\\s*path:\\s*\"(.*?)\")?(?:,\\s*exclude:\\s*(\\[(?:\\s*\".*?\",?\\s*)*\\]))?(?:,\\s*sources:\\s*(\\[(?:\\s*\".*?\",?\\s*)*\\]))?(?:,\\s*publicHeadersPath:\\s*\"(.*?)\")?\\)",
            options: []
        )
        let contents: String = try self.contents()
        
        return try pattern.matches(in: contents, range: contents.range).map { (result) -> Target in
            return try Target(match: result, in: contents, with: self)
        }
    }
    
    /// Gets a target declared in the project's manifest.
    ///
    /// - parameters:
    ///   - test: Wheather the target to fetch is a test target or not.
    ///   - name: The name of the target to fetch.
    ///
    /// - returns: The project's targets parsed into data structures.
    /// - throws: Errors that occur while fetching the manifest contents or create the regex for maching the targets.
    public func target(test: Bool = false, withName name: String)throws -> Target? {
        let type = test ? "(testT)arget" : "(t)arget"
        let pattern = try NSRegularExpression(
            pattern: "\\.\(type)\\(name:\\s*\"(\(name))\",\\s*dependencies:\\s*(\\[.*?\\])(?:,\\s*path:\\s*\"(.*?)\")?(?:,\\s*exclude:\\s*(\\[(?:\\s*\".*?\",?\\s*)*\\]))?(?:,\\s*sources:\\s*(\\[(?:\\s*\".*?\",?\\s*)*\\]))?(?:,\\s*publicHeadersPath:\\s*\"(.*?)\")?\\)",
            options: []
        )
        let contents: String = try self.contents()
        
        return try pattern.matches(in: contents, range: contents.range).map { (result) -> Target in
            print("result")
            return try Target(match: result, in: contents, with: self)
            }.first
    }
}
