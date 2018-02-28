import Foundation

fileprivate let brackets: CharacterSet = CharacterSet(charactersIn: "[]")
fileprivate let arrayString: CharacterSet = CharacterSet(charactersIn: " \"\n")

extension String {
    public func substring(at range: NSRange) -> String? {
        guard range.location != NSNotFound else {
            return nil
        }
        return NSString(string: self).substring(with: range)
    }
    
    public func parseArray(at range: NSRange) -> [String] {
        guard let representation = self.substring(at: range) else {
            return []
        }
        return representation.trimmingCharacters(in: brackets).split(separator: ",").map({ (sub) -> String in
            return String(sub).trimmingCharacters(in: arrayString)
        })
    }
    
    public var range: NSRange {
        return NSMakeRange(0, NSMutableString(string: self).length)
    }
}

extension NSMutableString {
    public var range: NSRange {
        return NSMakeRange(0, self.length)
    }
}
