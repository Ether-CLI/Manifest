import Foundation

/// An interface for a package's manifest.
public class Manifest {
    
    /// Gets the current project's manifest.
    public static let current = Manifest()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    
    /// Gets the contents of the project's manifest as `Data`.
    ///
    /// - Returns: The manifest's contents.
    /// - Throws: Errors that occur if there is a badly formed URL or the manifest is not found.
    func contents()throws -> Data {
        guard let resolvedURL = URL(string: "file:\(fileManager.currentDirectoryPath)/Package.swift") else {
            throw ManifestError(identifier: "badURL", reason: "Unable to create URL for package manifest file.")
        }
        if !fileManager.fileExists(atPath: "\(fileManager.currentDirectoryPath)/Package.swift") {
            throw ManifestError(identifier: "badManifestPath", reason: "Bad path to package manifest. Make sure you are in the project root.")
        }
        return try Data(contentsOf: resolvedURL)
    }
    
    /// Gets the contents of the project's manifest as a `String`.
    ///
    /// - Returns: The manifest's contents.
    /// - Throws: Errors that occur if there is a badly formed URL or the manifest is not found.
    func contents()throws -> String {
        guard let contents = try String(data: self.contents(), encoding: .utf8) else {
            throw ManifestError(identifier: "unableToConvertDataToString", reason: "The contents of the package's manifest could not be converted to a string with UTF-8 encoding.")
        }
        return contents
    }
    
    /// Rewrites the contents of the package's manifest.
    ///
    /// - Parameter string: The data to rewrite the manifest with.
    /// - Throws: `ManifestError.badURL` if the URL to the manifest cannot be created.
    func write(with string: String)throws {
        guard let manifestURL = URL(string: "file:\(fileManager.currentDirectoryPath)/Package.swift") else {
            throw ManifestError(identifier: "badURL", reason: "Unable to create URL for package manifest file.")
        }
        try string.data(using: .utf8)?.write(to: manifestURL)
    }
}
