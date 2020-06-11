//
//  Directory.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

public var homeDir: String {
    NSHomeDirectory()
}

@discardableResult
public func mkdir(_ directory: String, withIntermediates: Bool = true) -> Bool {
    do {
        try FileManager.default.createDirectory(atPath: directory.expandingPath(), withIntermediateDirectories: withIntermediates)
        return true
    } catch {
        printOrDie("Failed to create directory: \(directory)")
        return false
    }
}

public func scandir(_ directory: String, recursively: Bool = false) -> [String] {
    do {
        if recursively {
            let enumerator = FileManager.default.enumerator(atPath: directory.expandingPath())
            return enumerator?.allObjects as? [String] ?? []
        } else {
            return try FileManager.default.contentsOfDirectory(atPath: directory.expandingPath())
        }
    } catch {
        printOrDie("Failed to read directory: \(directory)")
        return []
    }
}

public func recurse(_ directory: String, predicate: (String) -> Bool, action: (String) throws -> Void) rethrows {
    let enumerator = FileManager.default.enumerator(atPath: directory.expandingPath())

    while let file = enumerator?.nextObject() as? String {
        if predicate(file) {
            try action(file)
        }
    }
}

public func recurse(_ directory: String, extensions: String..., action: (String) throws -> Void) rethrows {
    let enumerator = FileManager.default.enumerator(atPath: directory.expandingPath())

    while let file = enumerator?.nextObject() as? String {
        if extensions.isEmpty == false {
            if extensions.contains(where: file.hasSuffix) {
                try action(file)
            }
        } else {
            try action(file)
        }
    }
}

public func isdir(_ name: String) -> Bool {
    var isDir: ObjCBool = false

    if FileManager.default.fileExists(atPath: name.expandingPath(), isDirectory: &isDir) {
        if isDir.boolValue {
            return true
        }
    }

    return false
}

@discardableResult
public func rmdir(_ file: String) -> Bool {
    fileDelete(file)
}

public func getcwd() -> String {
    FileManager.default.currentDirectoryPath
}

@discardableResult
public func chdir(_ newDirectory: String) -> Bool {
    if FileManager.default.changeCurrentDirectoryPath(newDirectory.expandingPath()) {
        return true
    } else {
        printOrDie("Failed to change to directory \(newDirectory)")
        return false
    }
}
