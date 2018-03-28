import Foundation
import Utilities

/// A product that is vended by the parent package.
///
/// For more information, visit the [SPM docs](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#products).
public final class Product: CustomStringConvertible {
    
    /// Denotes wheather the product is a library or an executable.
    public let type: ProductType
    
    /// The name of the target.
    public var name: String
    
    /// How the product gets linked to a client project if it is a library.
    public var linking: LibraryLinkingType?
    
    /// The package's targets that the product can access.
    public var targets: [String]
    
    /// The name of the `Product` object
    /// when it is fetched from the manifest.
    internal var fetchedName: String?
    
    internal let manifest: Manifest
    
    ///
    public init(type: ProductType, name: String, linking: LibraryLinkingType?, targets: [String]) {
        self.type = type
        self.name = name
        self.linking = linking
        self.targets = targets
        self.manifest = Manifest.current
    }
    
    /// Used to create `Product` objects that who's data is fecthed from the project manifest.
    internal init(from manifest: Manifest, withType type: ProductType, name: String, linking: LibraryLinkingType?, targets: [String]) {
        self.type = type
        self.name = name
        self.linking = linking
        self.targets = targets
        
        self.fetchedName = name
        self.manifest = manifest
    }
    
    /// The product formatted for the manifest.
    public var description: String {
        return "." + type.rawValue + "(" +
            "name: \"\(self.name)\", " +
            ((type == .library && linking != nil) ? "type: .\(self.linking!.rawValue), " : "") +
            "targets: \(self.targets.description)" +
        ")"
    }
}

extension Manifest {
    
    /// Gets all the `Product` instances in the current manifest.
    public func products()throws -> [Product] {
        let pattern = try NSRegularExpression(
            pattern: "\\.(?:executable|library)\\(name\\s*:\\s*\"(.*?)\"\\s*(?:,\\s*type\\s*:\\s*\\.(static|dynamic)\\s*)?(?:,\\s*targets\\s*:\\s*(\\[.*?\\]))?",
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
}
