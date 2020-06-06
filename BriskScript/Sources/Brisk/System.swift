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

enum Brisk {
    static var haltOnError = false
}

func printOrDie(_ message: String) {
    if Brisk.haltOnError {
        fatalError(message)
    } else {
        print(message)
    }
}

func exit(_ message: String = "", code: Int = 0) -> Never {
    if message.isEmpty == false {
        print(message)
    }

    exit(Int32(code))
}

#if canImport(Cocoa)
func open(_ thing: String) {
    NSWorkspace.shared.openFile(thing)
}
#endif

/// Executes a bash command as is and returns the output
/// This is using `/usr/bin/env bash` (bash-5.0) since `/bin/bash` refers to older bash-3.2 on OSX
/// - Parameters:
///   - command: bash command as it would be typed in terminal. e.g. `ls -lah`
/// - Returns: `String` console output
func bash(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.arguments = ["bash", "-c", command]
    task.launchPath = "/usr/bin/env"
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}
