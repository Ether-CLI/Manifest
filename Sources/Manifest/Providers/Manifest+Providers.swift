import Foundation
import Utilities

extension Manifest {
    
    /// Get all the elements in `Package.providers` from the project's manifest.
    ///
    /// - Returns: `Package.providers`
    /// - Throws: Errors that occur when creating a RegEx pattern
    ///   or reading or writing the manifest.
    public func providers()throws -> [Provider] {
        let brew = try NSRegularExpression(pattern: "\\.brew\\((\\[.*?\\])\\)", options: [])
        let apt = try NSRegularExpression(pattern: "\\.apt\\((\\[.*?\\])\\)", options: [])
        let contents: String = try self.contents()
        
        let brewProviders: [Provider] = brew.matches(in: contents, options: [], range: contents.range).map { (match) in
            let packages = contents.parseArray(at: match.range(at: 1))
            return Provider(type: .brew, packages: packages, manifest: self)
        }
        let aptProviders: [Provider] = apt.matches(in: contents, options: [], range: contents.range).map { (match) in
            let packages = contents.parseArray(at: match.range(at: 1))
            return Provider(type: .apt, packages: packages, manifest: self)
        }
        
        return brewProviders + aptProviders
    }
}

