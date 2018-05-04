import Foundation

/// An interface for a package's manifest.
public class Manifest: Codable {
    
    /// The current environment that the `Manifest` is being used in.
    public static var environment: Environment = .commandline
    
    /// Gets the current project's manifest.
    public static var current: Manifest {
        if Manifest.environment == .commandline {
            return Manifest(path: "file:\(FileManager.default.currentDirectoryPath)/Package.swift")
        } else {
            return Manifest(data: Data(testManifest.utf8))
        }
    }
    
    /// A custom path to the manifest.
    /// This property gets set to `./Package.swift`
    /// when the static` .current` property is used.
    public let path: String?
    
    /// Data that acts as the manifest file.
    public private(set) var data: Data?
    
    internal let fileManager = FileManager.default
    
    ///
    public init(path: String) {
        self.path = path
    }
    
    ///
    public init(data: Data) {
        self.data = data
        self.path = nil
    }
    
    /// Gets the contents of the project's manifest as `Data`.
    ///
    /// - Returns: The manifest's contents.
    /// - Throws: Errors that occur if there is a badly formed URL or the manifest is not found.
    public func contents()throws -> Data {
        if let data = self.data {
            return data
        }
        
        guard let resolvedURL = URL(string: self.path!) else {
            throw ManifestError(identifier: "badURL", reason: "Unable to create URL for package manifest file.")
        }
        if !fileManager.fileExists(atPath: self.path!) {
            throw ManifestError(identifier: "badManifestPath", reason: "Bad path to package manifest. Make sure you are in the project root.")
        }
        
        return try Data(contentsOf: resolvedURL)
    }
    
    /// Gets the contents of the project's manifest as an `NSMutableString`.
    ///
    /// - Returns: The manifest's contents.
    /// - Throws: Errors that occur if there is a badly formed URL or the manifest is not found.
    public func contents()throws -> NSMutableString {
        let contents: String = try self.contents()
        return NSMutableString(string: contents)
    }
    
    /// Gets the contents of the project's manifest as a `String`.
    ///
    /// - Returns: The manifest's contents.
    /// - Throws: Errors that occur if there is a badly formed URL or the manifest is not found.
    public func contents()throws -> String {
        guard let contents = try String(data: self.contents(), encoding: .utf8) else {
            throw ManifestError(identifier: "unableToConvertDataToString", reason: "The contents of the package's manifest could not be converted to a string with UTF-8 encoding.")
        }
        return contents
    }
    
    /// Rewrites the contents of the package's manifest.
    ///
    /// - Parameter string: The data to rewrite the manifest with.
    /// - Throws: `ManifestError.badURL` if the URL to the manifest cannot be created.
    public func write(with string: String)throws {
        if self.data != nil {
            self.data = Data(string.utf8)
            return
        }
        
        if Manifest.environment == .testing { testManifest = string; return }
        
        guard let manifestURL = URL(string: self.path!) else {
            throw ManifestError(identifier: "badURL", reason: "Unable to create URL for package manifest file.")
        }
        
        try string.data(using: .utf8)?.write(to: manifestURL)
    }
    
    /// Rewrites the contents of the package's manifest.
    ///
    /// - Parameter string: The string to rewrite the manifest with.
    /// - Throws: `ManifestError.badURL` if the URL to the manifest cannot be created.
    public func write(with string: NSMutableString)throws {
        try self.write(with: String(string))
    }
    
    /// Rests the manifest to its orginal state when the project was created
    /// without extraneous comments or whitespace.
    ///
    /// - Throws: Errors when reading or writing the manifest.
    public func reset()throws {
        let toolPattern = try NSRegularExpression(pattern: "\\/\\/\\s*swift-tools-version\\s*:\\s*(.*)", options: [])
        let namePattern = try NSRegularExpression(pattern: "Package\\(\\s*name\\s*:\\s*\"(.*?)\"", options: [])
        let contents: NSMutableString = try self.contents()
        
        let toolRange = toolPattern.matches(in: String(contents), options: [], range: contents.range).first?.range(at: 1)
        let toolVersion = String(contents).substring(at: toolRange ?? NSRange()) ?? "4.0"
        
        let nameRange = namePattern.matches(in: String(contents), options: [], range: contents.range).first?.range(at: 1)
        let name = String(contents).substring(at: nameRange ?? NSRange()) ?? String(fileManager.currentDirectoryPath.split(separator: "/").last!)
        
        let manifest = """
        // swift-tools-version:\(toolVersion)

        import PackageDescription

        let package = Package(
            name: "\(name)",
            products: [
                .library(name: "\(name)", targets: ["\(name)"]),
            ],
            dependencies: [],
            targets: [
                .target(name: "\(name)", dependencies: []),
                .testTarget(name: "\(name)Tests", dependencies: ["\(name)"]),
            ]
        )
        """
        
        try self.write(with: manifest)
    }
}
