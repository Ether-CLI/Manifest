import XCTest
@testable import Manifest
@testable import Utilities

class ManifestTests: XCTestCase {
    func test()throws {
        Manifest.environment = .testing
        try print(Manifest.current.providers())
        try print(Manifest.current.contents() as String)
    }
    
    static var allTests: [(String, (ManifestTests)throws -> () -> ())] = []
}
