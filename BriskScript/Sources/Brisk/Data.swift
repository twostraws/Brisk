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
        guard let parsedURL = URL(string: url),
            let loadedData = Data(request: URLRequest(url: parsedURL)) else {
            printOrDie("Bad URL: \(url)")
            self = Data()
            return
        }

        self = loadedData
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
    
    init?(request: URLRequest) {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Data? = nil

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            result = data
            if let error = error {
                printOrDie("Fetched failed for \(String(describing: request.url)) – \(error.localizedDescription )")
            }

            semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        if let loadedData = result {
            self = loadedData
        } else {
            return nil
        }
    }
}
