//
//  XML.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

enum XML {
    class XMLNode {
        let tag: String
        var data: String
        let attributes: [String: String]
        var childNodes: [XMLNode]

        init(tag: String, data: String, attributes: [String: String], childNodes: [XMLNode] = []) {
            self.tag = tag
            self.data = data
            self.attributes = attributes
            self.childNodes = childNodes
        }

        func getElementsByTagName(_ name: String) -> [XMLNode] {
            var results = [XMLNode]()

            for node in childNodes {
                if node.tag == name {
                    results.append(node)
                }

                results += node.getElementsByTagName(name)
            }

            return results
        }

        func hasAttribute(_ name: String) -> Bool {
            attributes[name] != nil
        }

        func getAttribute(_ name: String) -> String {
            attributes[name, default: ""]
        }
    }

    class MicroDOM: NSObject, XMLParserDelegate {
        private let parser: XMLParser
        private var stack = [XMLNode]()
        private var tree: XMLNode?

        init(data: Data) {
            parser = XMLParser(data: data)
            super.init()
            parser.delegate = self
        }

        func parse() -> XMLNode? {
            parser.parse()

            guard parser.parserError == nil else {
                return nil
            }

            return tree
        }

        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
            let node = XMLNode(tag: elementName, data: "", attributes: attributeDict, childNodes: [])
            stack.append(node)
        }

        func parser(_ parser: XMLParser, foundCharacters string: String) {
            stack.last?.data = string
        }

        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            let lastElement = stack.removeLast()

            if let last = stack.last {
                last.childNodes += [lastElement]
            } else {
                tree = lastElement
            }
        }
    }
}

func parseXML(_ data: Data) -> XML.XMLNode? {
    let dom = XML.MicroDOM(data: data)
    return dom.parse()
}

func parseXML(_ string: String) -> XML.XMLNode? {
    let data = Data(string.utf8)
    let dom = XML.MicroDOM(data: data)
    return dom.parse()
}

func parseXML(from file: String) -> XML.XMLNode? {
    guard let string = String(file: file) else { return nil }
    let data = Data(string.utf8)
    let dom = XML.MicroDOM(data: data)
    return dom.parse()
}
