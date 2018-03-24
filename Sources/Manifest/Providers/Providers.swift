import Foundation
import Utilities

/// Respresents a system package manager and the packages that should be installed through that given package manager.
///
/// More information [here](https://github.com/apple/swift-package-manager/blob/master/Documentation/PackageDescriptionV4.md#providers)
struct Provider {
    
    /// The packages to suggest installation for.
    var packages: [String]
    
    ///
    private init(packages: [String]) {
        self.packages = packages
    }
}
