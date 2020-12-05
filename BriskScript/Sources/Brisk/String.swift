//
//  String.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation
import CryptoKit

extension String {
    var lines: [String] {
        components(separatedBy: .newlines)
    }

    static func / (lhs: String, rhs: String) -> String {
        "\(lhs)/\(rhs)"
    }

    func md5() -> String {
        let data = Data(self.utf8)
        let hashed = Insecure.MD5.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func sha1() -> String {
        let data = Data(self.utf8)
        let hashed = Insecure.SHA1.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func sha256() -> String {
        let data = Data(self.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func base64() -> String {
        Data(utf8).base64EncodedString()
    }

    @discardableResult
    func write(to file: String) -> Bool {
        do {
            try self.write(toFile: file.expandingPath(), atomically: true, encoding: .utf8)
            return true
        } catch {
            printOrDie("Failed to write \(file.expandingPath()): \(error.localizedDescription)")
            return false
        }
    }

    func replacing(_ search: String, with replacement: String) -> String {
        self.replacingOccurrences(of: search, with: replacement)
    }

    mutating func replace(_ search: String, with replacement: String) {
        self = self.replacingOccurrences(of: search, with: replacement)
    }

    /**
     Replaces occurences of one string with another, up to `count` times.
     - Parameter of: The string to look for.
     - Parameter with: The string to replace.
     - Parameter count: The maximum number of replacements
     - Returns: The string with replacements made.
     */
    func replacing(_ search: String, with replacement: String, count maxReplacements: Int) -> String {
        var count = 0
        var returnValue = self

        while let range = returnValue.range(of: search) {
            returnValue = returnValue.replacingCharacters(in: range, with: replacement)
            count += 1

            // exit as soon as we've made all replacements
            if count == maxReplacements {
                return returnValue
            }
        }

        return returnValue
    }

    mutating func replace(_ search: String, with replacement: String, count maxReplacements: Int) {
        self = replacing(search, with: replacement, count: maxReplacements)
    }

    mutating func trim(_ characters: String = " \t\n\r\0") {
        self = self.trimmingCharacters(in: CharacterSet(charactersIn: characters))
    }

    func trimmed(_ characters: String = " \t\n\r\0") -> String {
        self.trimmingCharacters(in: CharacterSet(charactersIn: characters))
    }

    func matches(regex: String, options: NSRegularExpression.Options = []) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: options)
            let matches = regex.matches(in: self, range: NSRange(location: 0, length: self.utf16.count))
            return matches.count > 0
        } catch {
            return false
        }
    }

    func replacing(regex: String, with replacement: String, options: NSString.CompareOptions) -> String {
        self.replacingOccurrences(of: regex, with: replacement, options: options.union([.regularExpression]))
    }

    mutating func replace(regex: String, with replacement: String, options: NSString.CompareOptions) {
        self = self.replacingOccurrences(of: regex, with: replacement, options: options.union([.regularExpression]))
    }

	func getCapturedGroupsFrom(regexPattern: String)-> [String]? {
		let text = self
		let regex = try? NSRegularExpression(pattern: regexPattern)
		let match = regex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text))

		if let match = match {
			return (0..<match.numberOfRanges).compactMap {
				$0 > 0 ? String(text[Range(match.range(at: $0), in: text)!]) : nil
			}
		}
		return nil
	}

    /**
     Lets you read one character from this string using its integer index
     */
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }

    /**
     Lets you read a slice of a string using a regular int range.
     */
    subscript(range: Range<Int>) -> String {
        guard range.lowerBound < count else { return "" }
        guard range.upperBound < count else { return self[range.lowerBound...] }

        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start ..< end])
    }

    /**
     Lets you read a slice of a string using a regular int range.
     */
    subscript(range: ClosedRange<Int>) -> String {
        guard range.lowerBound < count else { return "" }
        guard range.upperBound < count else { return self[range.lowerBound...] }

        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start ... end])
    }

    /**
     Lets you read a slice of a string using a partial range from, e.g. 3...
     */
    subscript(range: CountablePartialRangeFrom<Int>) -> String {
        guard range.lowerBound < count else { return "" }
        let start = index(startIndex, offsetBy: range.lowerBound)
        return String(self[start ..< endIndex])
    }

    /**
     Lets you read a slice of a string using a partial range through, e.g. ...3
     */
    subscript(range: PartialRangeThrough<Int>) -> String {
        guard range.upperBound < count else { return self }
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[startIndex ... end])
    }

    /**
     Lets you read a slice of a string using a partial range up to, e.g. ..<3
     */
    subscript(range: PartialRangeUpTo<Int>) -> String {
        guard range.upperBound < count else { return self }
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[startIndex ..< end])
    }

    func expandingPath() -> String {
        var result = self

        if result.first == "~" {
            result = homeDir + result.dropFirst()
        } else if result.first == "." {
            result = getcwd() + result.dropFirst()
        }

        return result
    }

    init(url: String) {
        let data = Data(url: url)
        self = String(decoding: data, as: UTF8.self)
    }

    init?(file: String) {
        do {
            self = try String(contentsOfFile: file.expandingPath())
        } catch {
            if Brisk.haltOnError {
                exit("Unable to read contents of \(file).")
            } else {
                return nil
            }
        }
    }

    /**
     Deletes a prefix from a string; does nothing if the prefix doesn't exist.
     */
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    /**
     Deletes a suffix from a string; does nothing if the suffix doesn't exist.
     */
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }

    /**
     Ensures a string starts with a given prefix.
     Parameter prefix: The prefix to ensure.
     */
    func withPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) { return self }
        return "\(prefix)\(self)"
    }

    /**
     Ensures a string ends with a given suffix.
     Parameter suffix: The suffix to ensure.
     */
    func withSuffix(_ suffix: String) -> String {
        if self.hasSuffix(suffix) { return self }
        return "\(self)\(suffix)"
    }
}
