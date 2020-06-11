//
//  Settings.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

#if canImport(Cocoa)
import Cocoa
#endif

public enum Brisk {
    public static var haltOnError = false
}

public func printOrDie(_ message: String) {
    if Brisk.haltOnError {
        fatalError(message)
    } else {
        print(message)
    }
}

public func exit(_ message: String = "", code: Int = 0) -> Never {
    if message.isEmpty == false {
        print(message)
    }

    exit(Int32(code))
}

#if canImport(Cocoa)
public func open(_ thing: String) {
    NSWorkspace.shared.openFile(thing)
}
#endif
