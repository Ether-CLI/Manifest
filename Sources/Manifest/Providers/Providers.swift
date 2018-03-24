import Foundation
import Utilities

/// Respresents a system package manager and the packages that should be installed through that given package manager.
///
/// More information [here](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#providers)
public struct Provider {
    
    /// The packages to suggest installation for.
    public var packages: [String]
    
    /// The manifest instance used to mutate or fetch
    /// information from the project's manifest.
    private let manifest: Manifest
    
    ///
    private init(packages: [String], manifest: Manifest? = nil) {
        self.packages = packages
        self.manifest = manifest ?? Manifest.current
    }
}

/// Designates which package manager the provider is for.
public enum ProviderType {
    
    ///
    case brew
    
    ///
    case apt
}
