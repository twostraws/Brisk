//
//  Process.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

func getpid() -> Int {
    Int(ProcessInfo.processInfo.processIdentifier)
}

func getHostName() -> String {
    ProcessInfo.processInfo.hostName
}

func getUserName() -> String {
    ProcessInfo.processInfo.userName
}

func getenv(_ key: String) -> String {
    ProcessInfo.processInfo.environment[key, default: ""]
}

func setenv(_ key: String, _ value: String) {
    setenv(key, value, 1)
}
