import Foundation

struct ManifestError: Error {
    let identifier: String
    let reason: String
}

extension ManifestError {
    static func noStringAtRange(_ range: NSRange) -> ManifestError {
        return ManifestError(identifier: "noStringAtRange", reason: "No substring exists in string at range '\(range)'")
    }
}
