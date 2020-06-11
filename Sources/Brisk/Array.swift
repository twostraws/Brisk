//
//  Array.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(_ obj: Element) {
        self = self.filter { $0 != obj }
    }
}
