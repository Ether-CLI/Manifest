import Foundation

extension Manifest {
    
    /// Gets the contents of the package's `Package.resolved` file as a data structure.
    ///
    /// - Returns: The contents of the packages `.resolved` file.
    /// - Throws: `ManifestError.badPath` if the path to the `.resolved` file is malformed.
    func resolved()throws -> Resolved {
        guard let resolvedURL = URL(string: "file:\(fileManager.currentDirectoryPath)/Package.resolved") else {
            throw ManifestError(identifier: "badPath", reason: "Bad path to package data. Make sure you are in the project root.")
        }
        let resolved = try Data(contentsOf: resolvedURL)
        return try JSONDecoder().decode(Resolved.self, from: resolved)
    }
}
