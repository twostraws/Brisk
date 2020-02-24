//
//  Data.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation
import CryptoKit

extension Data {
    func md5() -> String {
        let hashed = Insecure.MD5.hash(data: self)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func sha1() -> String {
        let hashed = Insecure.SHA1.hash(data: self)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func sha256() -> String {
        let hashed = SHA256.hash(data: self)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func base64() -> Data {
        base64EncodedData()
    }

    @discardableResult
    func write(to file: String) -> Bool {
        do {
            let url = URL(fileURLWithPath: file.expandingPath())
            try self.write(to: url, options: .atomic)
            return true
        } catch {
            printOrDie("Failed to write \(file.expandingPath()): \(error.localizedDescription)")
            return false
        }
    }

    init(url: String) {
        guard let parsedURL = URL(string: url) else {
            printOrDie("Bad URL: \(url)")
            self = Data()
            return
        }

        let semaphore = DispatchSemaphore(value: 0)
        var result = Data()

        let task = URLSession.shared.dataTask(with: parsedURL) { data, _, error in
            if let data = data {
                result = data
            } else {
                printOrDie("Fetched failed for \(url) – \(error?.localizedDescription ?? "Unknown error")")
            }

            semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        self = result
    }

    init?(file: String) {
        do {
            let contents = try String(contentsOfFile: file.expandingPath())
            self = Data(contents.utf8)
        } catch {
            if Brisk.haltOnError {
                exit("Unable to read contents of \(file).")
            } else {
                return nil
            }
        }
    }
}
