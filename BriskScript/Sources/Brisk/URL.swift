//
//  Comparable.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

extension URL {
    /**
     Create new URLs by appending strings
     - Parameter lhs: The base URL to use
     - Parameter rhs: The string to append
     - Returns: A new URL combining the two
     */
    static func +(lhs: URL, rhs: String) -> URL {
        return lhs.appendingPathComponent(rhs)
    }

    static func +=(lhs: inout URL, rhs: String) {
        lhs.appendPathComponent(rhs)
    }
}
