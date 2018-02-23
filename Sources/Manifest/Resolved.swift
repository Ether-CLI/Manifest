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
    
    /// Gets the data from the package's `.resolved` file about a package with a given name.
    ///
    /// - Parameter name: The name of the package to fetch.
    /// - Returns: The package's pin data.
    /// - Throws: Errors that occur when fetching the data.
    func package(withName name: String)throws -> Pin? {
        return try self.resolved().object.pins.filter({ $0.package == name }).first
    }
}
