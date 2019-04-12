//
//  VaultItem.swift
//  Mind Vault
//
//  Created by Michel Roovers on 16/02/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class VaultItem: NSObject {
    var path : String = ""
    var value: String = ""
    var mode: eVaultMode = eVaultMode.pasteBoard
    var header: String  = ""
    var tableData: String = ""
    var valueNode: XMLNode = XMLNode(kind: XMLNode.Kind.comment)
    var howtoSteps = Array<HowtoStep>()
    
    var filePath : String = ""
    
    enum eVaultMode { case none, pasteBoard, dialog, table, tableFile, howto, howtoFile, pictureFile }
    
    override init() {
        filePath = NSHomeDirectory() + "/.mindvault/"
    }
    
    init(path:String, value:String, mode:eVaultMode) {
        self.path = path
        self.value = value
        self.mode = mode

        filePath = NSHomeDirectory() + "/.mindvault/"
    }
    
    func name() -> String {
        return path
    }
    
    func pathElements() -> Array<String> {
        var result : Array<String> = Array<String>()
        for elem in self.path.components(separatedBy: ".") {
            result.append(elem)
        }
        return result
    }
    
    func headerElements() -> Array<String> {
        var result : Array<String> = Array<String>()
        if self.header == "" {
            self.setData()
        }
        
        for elem in self.header.components(separatedBy: "\t") {
            result.append(elem)
        }
        return result
    }
    

    static func fromXmlNode(node : XMLNode) -> VaultItem? {
        var nodePath : String = ""
        var nodeValue : String = ""
        var nodeHeader : String = ""
        var mode = eVaultMode.none
        var valueNode : XMLNode = node
        
        for child in node.children! {
            if child.name == "path" {
                nodePath = child.stringValue!
            }
            if child.name == "value" {
                nodeValue = child.stringValue!
                valueNode = child
            }
            if child.name == "mode" {
                switch child.stringValue {
                case "dialog"?:
                    mode = eVaultMode.dialog
                case "table"?:
                    mode = eVaultMode.table
                case "tableFile"?:
                    mode = eVaultMode.tableFile
                case "howto"?:
                    mode = eVaultMode.howto
                case "howtoFile"?:
                    mode = eVaultMode.howtoFile
                case "pictureFile"?:
                    mode = eVaultMode.pictureFile
                case "pasteBoard"?:
                    mode = eVaultMode.pasteBoard
                default:
                    mode = eVaultMode.none
                }
            }
            if child.name == "header" {
                nodeHeader = child.stringValue!
            }
        }
        
        if nodePath != "" && nodeValue != "" {
            let result = VaultItem(path: nodePath, value: nodeValue, mode: mode)
            result.header = nodeHeader
            result.valueNode = valueNode
            return result
        }
        
        return nil
        
    }
    
    func numberOfColumns() -> Int {
        return self.headerElements().count
    }
    
    func numberOfRows() -> Int {
        if data.isEmpty || mode == eVaultMode.tableFile {
            setData()
        }
        
        return data.keys.count
    }
    
    func getData() -> [Int: [String]] {
        if data.isEmpty {
            setData()
        }
        
        return data
    }
    
    var data = [Int: [String]]()
    func setData() {
        if mode == eVaultMode.tableFile {
            loadTableFromFile()
        }
        
        var index : Int = 0
        for rows in self.tableData.components(separatedBy: "\n") {
            var cells = [String]()
            for cell in rows.components(separatedBy: "\t") {
                cells.append((cell))
            }

            if cells.count > 0 {
                self.data[index] = cells
                index += 1
            }
        }
    }
    
    func loadTableFromFile() {
        let url: URL = URL(fileURLWithPath: NSHomeDirectory() + "/.mindvault/" + value)
        NSLog(String("Table from file: " + url.absoluteString))
        do {
            let doc = try XMLDocument(contentsOf: url, options: XMLNode.Options.nodePreserveAll)
            for node in (doc.rootElement()?.children!)! {
                if node.name == "value" {
                    tableData = node.stringValue!
                }
                if node.name == "header" {
                    header = node.stringValue!
                }
            }
        } catch {
            NSLog("Problem loading embedded resource: %@", error.localizedDescription)
        }
    }
    
    func numberOfSteps() -> Int {
        if !hasSteps() || mode == eVaultMode.howtoFile {
            setSteps()
        }
        
        return howtoSteps.count
    }
    
    func howtoTags() -> Array<String> {
        var result = Array<String>()
        for step in howtoSteps {
            result.append(step.tag)
        }
        return result
    }
    
    func hasSteps() -> Bool {
        return howtoSteps.count > 0
    }
    
    func getStep(step: Int) -> HowtoStep? {
        if !hasSteps() {
            setSteps()
        }
        
        return step >= 0 && step < howtoSteps.count ? howtoSteps[step] : nil
    }
    
    func setSteps() {
        howtoSteps.removeAll()
        
        if mode == eVaultMode.howtoFile {
            // Load steps from file
            loadStepsFromFile()
            return
        }
        
        for node in valueNode.children! {
            if let step = HowtoStep.fromXmlNode(node: node) {
                howtoSteps.append(step)
            }
        }
    }
    
    func loadStepsFromFile() {
        let url: URL = URL(fileURLWithPath: filePath + value)
        NSLog(String("Howto from file: " + url.absoluteString))
        do {
            let doc = try XMLDocument(contentsOf: url, options: XMLNode.Options.nodePreserveAll)
            for node in (doc.rootElement()?.children!)! {
                if node.name == "step" {
                    if let step = HowtoStep.fromXmlNode(node: node) {
                        howtoSteps.append(step)
                    }
                }
            }
        } catch {
            NSLog("Problem loading embedded resource: %@", error.localizedDescription)
        }
    }
    
    
}
