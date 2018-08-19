//
//  AppDelegate.swift
//  Mind Vault
//
//  Created by Michel Roovers on 03/02/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        loadVault()
        
    }
    
    var vaultItems = Array<VaultItem>()
    
    func loadVault() {
        // First load the vault items from the file system
        openVault()
        
        // Add the embedded about Mindvault to vault
        if let filepath = Bundle.main.path(forResource: "howto-use-mindvault", ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: filepath)
                
                let doc = try XMLDocument(xmlString: contents, options: XMLNode.Options.nodePreserveAll)
                for node in (doc.rootElement()?.children!)! {
                    if let item = VaultItem.fromXmlNode(node: node) {
                        vaultItems.append(item)
        
                    }
                }
            } catch {
                NSLog("Problem loading embedded resource: %@", error.localizedDescription)
            }
        }
        
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(printQuote(_:))
            
            // Create the menu for the ststuabar button
            statusItem.menu = createMenu()
            
        }
    }
    
    func openVault() {
        vaultItems.removeAll()

        let url: URL = URL(fileURLWithPath: NSHomeDirectory() + "/.mindvault")
        NSLog(String("Item store: " + url.absoluteString))
    
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            let itemFiles = directoryContents.filter{ $0.pathExtension == "xml" }
        
            for itemFile in itemFiles {
                do {
                    let doc = try XMLDocument(contentsOf: itemFile, options: XMLNode.Options.nodePreserveAll)
                    for node in (doc.rootElement()?.children!)! {
                        if let item = VaultItem.fromXmlNode(node: node) {
                            vaultItems.append(item)

                        }
                    }
                } catch {
                    NSLog("Problem loading: %@ %@", itemFile.absoluteString, error.localizedDescription)
                }
            }
        } catch {
            NSLog(String("Problem loading: " + error.localizedDescription))
        }

    }

    /*!
     This method creates a tow dimensional meni from the vault items
    */
    func  createMenu() -> NSMenu {
        let menu = NSMenu()

        for item in vaultItems {
            var level: Int = 0
            var menuItem : NSMenuItem?
            var newItem : NSMenuItem?
            for elem in item.pathElements() {
                if level == 0 {
                    newItem = getMenuItem(title: elem, menu: menu)
                    if newItem == nil {
                        newItem = NSMenuItem(title: elem, action: nil, keyEquivalent: "")
                        menu.addItem( newItem!)
                    }
                    menuItem = newItem
                }
                
                if level > 0 {
                    newItem = getSubMenuItem(title: elem, menuItem: newItem!)
                    
                    if newItem == nil {
                        newItem = NSMenuItem(title: elem, action: nil, keyEquivalent: "")
                        
                        if menuItem?.hasSubmenu == false {
                            menuItem?.submenu = NSMenu()
                        }
                        
                        menuItem?.submenu?.addItem(newItem!)
                    }
                    menuItem = newItem
                }
                level += 1
            }
            
            if newItem != nil {
                newItem?.tag = vaultItems.index(of: item)!
                newItem?.action = #selector(action1(_:))
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Reload", action: #selector(reloadAction(_:)), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exitAction(_:)), keyEquivalent: "k"))
        
        return menu
        
    }
    
    func getMenuItem(title: String, menu: NSMenu) -> NSMenuItem? {
        if menu.items.count > 0 {
            for menuItem in menu.items {
                if menuItem.title == title {
                    return menuItem
                }
            }
        }
        return nil
    }

    func getSubMenuItem(title: String, menuItem: NSMenuItem) -> NSMenuItem? {
        if  menuItem.hasSubmenu {
            for item in (menuItem.submenu?.items)! {
                if item.title == title {
                    return item
                }
            }
        }
        return nil
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
    }

    @objc func action1(_ sender: Any?) {
        let menuItem : NSMenuItem = sender as! NSMenuItem
        let item: VaultItem = vaultItems[menuItem.tag]
        
        switch item.mode {
        case VaultItem.eVaultMode.pasteBoard:
            copyToPasteboard(text: item.value)

        case VaultItem.eVaultMode.dialog:
            NSLog("open tableFile")
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VaultText")) as! VaultTextWindowController
            wc.showWindow(self)
            wc.attachValueItem(item: item)
            NSApp.activate(ignoringOtherApps: true)

        case VaultItem.eVaultMode.table, VaultItem.eVaultMode.tableFile:
            NSLog("open tableFile")
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VaultTable")) as! VaultTableWindowController
            wc.showWindow(self)
            wc.attachValueItem(item: item)
            NSApp.activate(ignoringOtherApps: true)
            
        case VaultItem.eVaultMode.howto, VaultItem.eVaultMode.howtoFile:
            NSLog("open howtoFile")
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VaultHowto")) as! VaultHowtoWindowController
            wc.showWindow(self)
            wc.attachValueItem(item: item)
            NSApp.activate(ignoringOtherApps: true)

        }
    }
    
    @objc func reloadAction(_ sender: Any?) {
        loadVault()
    }

    @objc func exitAction(_ sender: Any?) {
        exit(EXIT_SUCCESS)
    }
    
    @objc func printQuote(_ sender: Any?) {
        NSLog("printQuote")
    }
    
    func copyToPasteboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: NSPasteboard.PasteboardType.string)

    }

}

