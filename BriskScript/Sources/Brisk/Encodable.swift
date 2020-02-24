//
//  Encodable.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

extension Encodable {
    func jsonData(keys: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dates: JSONEncoder.DateEncodingStrategy = .deferredToDate) -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keys
        encoder.dateEncodingStrategy = dates

        do {
            return try encoder.encode(self)
        } catch {
            printOrDie("Failed to encode to JSON.")
            return Data()
        }
    }

    func jsonString(keys: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys, dates: JSONEncoder.DateEncodingStrategy = .deferredToDate) -> String {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = keys
        encoder.dateEncodingStrategy = dates

        do {
            let data = try encoder.encode(self)
            return String(decoding: data, as: UTF8.self)
        } catch {
            printOrDie("Failed to encode to JSON.")
            return ""
        }
    }
}
