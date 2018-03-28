import Foundation
import Utilities

extension Manifest {
    
    /// Gets all the `Product` instances in the current manifest.
    public func products()throws -> [Product] {
        let pattern = try NSRegularExpression(
            pattern: "\\.(executable|library)\\(name\\s*:\\s*\"(.*?)\"\\s*(?:,\\s*type\\s*:\\s*\\.(static|dynamic)\\s*)?(?:,\\s*targets\\s*:\\s*(\\[.*?\\]))?",
            options: []
        )
        let contents: String = try self.contents()
        
        return try pattern.matches(in: contents, options: [], range: contents.range).map({ (match) in
            guard let raw = contents.substring(at: match.range(at: 1)), let type = ProductType(rawValue: raw) else {
                throw ManifestError.noStringAtRange(match.range(at: 1))
            }
            guard let name = contents.substring(at: match.range(at: 2)) else {
                throw ManifestError.noStringAtRange(match.range(at: 2))
            }
            
            let linking = LibraryLinkingType(rawValue: contents.substring(at: match.range(at: 3)) ?? "")
            let targets = contents.parseArray(at: match.range(at: 4))
            
            return Product(from: self, withType: type, name: name, linking: linking, targets: targets)
        })
    }
    
    /// Gets a single `Product` instances from the current manifest.
    ///
    /// - Parameters:
    ///   - type: Wheather the product is an `executable` or `library` (default).
    ///   - name: The name of the product to fetch.
    public func product(as type: ProductType = .library, withName name: String)throws -> Product? {
        let pattern = try NSRegularExpression(
            pattern: "\\.(\(type.rawValue))\\(name\\s*:\\s*\"(\(name))\"\\s*(?:,\\s*type\\s*:\\s*\\.(static|dynamic)\\s*)?(?:,\\s*targets\\s*:\\s*(\\[.*?\\]))?",
            options: []
        )
        let contents: String = try self.contents()
        
        return try pattern.matches(in: contents, options: [], range: contents.range).map({ (match) in
            guard let raw = contents.substring(at: match.range(at: 1)), let type = ProductType(rawValue: raw) else {
                throw ManifestError.noStringAtRange(match.range(at: 1))
            }
            guard let name = contents.substring(at: match.range(at: 2)) else {
                throw ManifestError.noStringAtRange(match.range(at: 2))
            }
            
            let linking = LibraryLinkingType(rawValue: contents.substring(at: match.range(at: 3)) ?? "")
            let targets = contents.parseArray(at: match.range(at: 4))
            
            return Product(from: self, withType: type, name: name, linking: linking, targets: targets)
        }).first
    }
}

