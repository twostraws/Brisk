//
//  File.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

@discardableResult
public func fileCreate(_ file: String, contents: Data? = nil) -> Bool {
    if FileManager.default.createFile(atPath: file.expandingPath(), contents: contents) {
        return true
    } else {
        printOrDie("Failed to create file: \(file)")
        return false
    }
}

@discardableResult
public func fileDelete(_ file: String) -> Bool {
    do {
        try FileManager.default.removeItem(atPath: file.expandingPath())
        return true
    } catch {
        printOrDie("Failed to delete \(file)")
        return false
    }
}

public func fileExists(_ name: String) -> Bool {
    FileManager.default.fileExists(atPath: name.expandingPath())
}

public func fileProperties(_ file: String) -> [FileAttributeKey: Any] {
    do {
        return try FileManager.default.attributesOfItem(atPath: file.expandingPath())
    } catch {
        printOrDie("Failed to open \(file) for reading.")
        return [:]
    }
}

public func fileSize(_ file: String) -> UInt64 {
    do {
        let attr = try FileManager.default.attributesOfItem(atPath: file.expandingPath())
        if let fileSize = attr[.size] as? UInt64 {
            return fileSize
        } else {
            printOrDie("Failed to read size of \(file).")
            return 0
        }
    } catch {
        printOrDie("Failed to read size of \(file).")
        return 0
    }
}

public func fileCreation(_ file: String) -> Date {
    do {
        let attr = try FileManager.default.attributesOfItem(atPath: file.expandingPath())
        if let date = attr[.creationDate] as? Date {
            return date
        } else {
            printOrDie("Failed to read creation date of \(file).")
            return Date()
        }
    } catch {
        printOrDie("Failed to read creation date of \(file).")
        return Date()
    }
}

public func fileModified(_ file: String) -> Date {
    do {
        let attr = try FileManager.default.attributesOfItem(atPath: file.expandingPath())
        if let date = attr[.modificationDate] as? Date {
            return date
        } else {
            printOrDie("Failed to read modification date of \(file).")
            return Date()
        }
    } catch {
        printOrDie("Failed to read modification date of \(file).")
        return Date()
    }
}

public func tempFile() -> String {
    NSTemporaryDirectory() + UUID().uuidString
}

public func basename(of file: String) -> String {
    URL(fileURLWithPath: file).lastPathComponent
}

@discardableResult
public func fileCopy(_ from: String, to: String) -> Bool {
    let fromPath = from.expandingPath()
    var toPath = to.expandingPath()

    var isDir: ObjCBool = false

    if FileManager.default.fileExists(atPath: toPath, isDirectory: &isDir) {
        if isDir.boolValue {
            toPath += ""/basename(of: fromPath)
        }
    }

    do {
        try FileManager.default.copyItem(atPath: fromPath, toPath: toPath)
        return true
    } catch {
        printOrDie("Failed to copy \(fromPath) to \(toPath). Error: \(error.localizedDescription)")
        return false
    }
}

