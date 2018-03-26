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
    
    ///
    init(type: ProductType, name: String, linking: LibraryLinkingType?, targets: [String]) {
        self.type = type
        self.name = name
        self.linking = linking
        self.targets = targets
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
