import Foundation
import Utilities

/// A product that is vended by the parent package.
///
/// For more information, visit the [SPM docs](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#products).
public final class Product: CustomStringConvertible, Encodable {
    
    /// Keys used of encoding a `Product` object.
    public typealias CodingKeys = ProductCodingKeys
    
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
    
    /// Encodes the objects public properties to an encoder
    ///
    /// - Parameter encoder: The encoder the properties get encoded to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ProductCodingKeys.self)
        try container.encode(self.type.rawValue, forKey: .type)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.targets, forKey: .targets)
        try container.encodeIfPresent(self.linking?.rawValue, forKey: .linking)
    }
}

/// Keys used of encoding a `Product` object.
public enum ProductCodingKeys: String, CodingKey {
    
    ///
    case type
    
    ///
    case name
    
    ///
    case linking
    
    ///
    case targets
}
