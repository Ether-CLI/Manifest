import Foundation

extension Manifest {
    
    /// Gets the contents of the package's `Package.resolved` file as `Data`.
    ///
    /// - Returns: The contents of the packages `.resolved` file.
    /// - Throws: `ManifestError.badPath` if the path to the `.resolved` file is malformed.re
    func resolved()throws -> Data {
        guard let resolvedURL = URL(string: "file:\(fileManager.currentDirectoryPath)/Package.resolved") else {
            throw ManifestError(identifier: "badPath", reason: "Bad path to package data. Make sure you are in the project root.")
        }
        return try Data(contentsOf: resolvedURL)
    }
}
