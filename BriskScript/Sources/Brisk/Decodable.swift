//
//  Encodable.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

func decode<T: Decodable>(string input: String, as type: T.Type, keys: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dates: JSONDecoder.DateDecodingStrategy = .deferredToDate) -> T {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = keys
    decoder.dateDecodingStrategy = dates

    let fileData = Data(input.utf8)

    do {
        return try decoder.decode(type, from: fileData)
    } catch {
        exit("Failed to decode \(input) as \(type)", code: 1)
    }
}

func decode<T: Decodable>(file: String, as type: T.Type, keys: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dates: JSONDecoder.DateDecodingStrategy = .deferredToDate) -> T {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = keys
    decoder.dateDecodingStrategy = dates

    guard let fileData = Data(file: file) else {
        exit("Failed to load \(file) for decoding.")
    }

    do {
        return try decoder.decode(type, from: fileData)
    } catch {
        exit("Failed to decode \(file) as \(type)", code: 1)
    }
}

extension Decodable {
    init(url: String, keys: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys, dates: JSONDecoder.DateDecodingStrategy = .deferredToDate) {
        let data = Data(url: url)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keys
        decoder.dateDecodingStrategy = dates

        if let decoded = try? decoder.decode(Self.self, from: data) {
            self = decoded
        } else {
            exit("Unable to decode \(Self.self) from \(url)")
        }
    }
}
