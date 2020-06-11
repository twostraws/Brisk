//
//  XML.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

public enum XML {
    public class XMLNode {
        public let tag: String
        public var data: String
        public let attributes: [String: String]
        public var childNodes: [XMLNode]

        public init(tag: String, data: String, attributes: [String: String], childNodes: [XMLNode] = []) {
            self.tag = tag
            self.data = data
            self.attributes = attributes
            self.childNodes = childNodes
        }

        public func getElementsByTagName(_ name: String) -> [XMLNode] {
            var results = [XMLNode]()

            for node in childNodes {
                if node.tag == name {
                    results.append(node)
                }

                results += node.getElementsByTagName(name)
            }

            return results
        }

        public func hasAttribute(_ name: String) -> Bool {
            attributes[name] != nil
        }

        public func getAttribute(_ name: String) -> String {
            attributes[name, default: ""]
        }
    }

    class MicroDOM: NSObject, XMLParserDelegate {
        private let parser: XMLParser
        private var stack = [XMLNode]()
        private var tree: XMLNode?

        public init(data: Data) {
            parser = XMLParser(data: data)
            super.init()
            parser.delegate = self
        }

        public func parse() -> XMLNode? {
            parser.parse()

            guard parser.parserError == nil else {
                return nil
            }

            return tree
        }

        public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
            let node = XMLNode(tag: elementName, data: "", attributes: attributeDict, childNodes: [])
            stack.append(node)
        }

        public func parser(_ parser: XMLParser, foundCharacters string: String) {
            stack.last?.data = string
        }

        public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            let lastElement = stack.removeLast()

            if let last = stack.last {
                last.childNodes += [lastElement]
            } else {
                tree = lastElement
            }
        }
    }
}

public func parseXML(_ data: Data) -> XML.XMLNode? {
    let dom = XML.MicroDOM(data: data)
    return dom.parse()
}

public func parseXML(_ string: String) -> XML.XMLNode? {
    let data = Data(string.utf8)
    let dom = XML.MicroDOM(data: data)
    return dom.parse()
}

public func parseXML(from file: String) -> XML.XMLNode? {
    guard let string = String(file: file) else { return nil }
    let data = Data(string.utf8)
    let dom = XML.MicroDOM(data: data)
    return dom.parse()
}
