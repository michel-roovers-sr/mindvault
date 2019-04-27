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
    
    func play() {
//        do {
//        }
//        catch {
//            NSLog("Encoding went wrong: @", error.localizedDescription)
//        }
    }

    class openedWindow: NSObject {
        init(title: String, wc: NSWindowController) {
            self.title = title
            self.wc = wc
        }
        
        var title: String = ""
        var wc: NSWindowController
        
    }
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    let windowsMenu = NSMenuItem(title: "Windows", action: nil, keyEquivalent: "")
    
    var openWindows: [Int: openedWindow] = [:]
    var openedWindows: Int = 1
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        loadVault()
        
        play()
        
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
            
            // Detach the Windows sub-menu before creating the new menu tree
            if statusItem.menu != nil {
                let noMindvaults = getNumberOfMenuItemsByTitle(title: "Mindvault", menu: (statusItem.menu)!)

                if let mnuItem = getMenuItem(title: "Mindvault", menu: statusItem.menu!, searchIndex: noMindvaults) {
                    if let winMenu = getSubMenuItem(title: "Windows", menuItem: mnuItem) {
                        mnuItem.submenu?.removeItem(winMenu)
                    }
                }
            }
            
            // Create the menu for the statusbar button
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
     This method creates a two dimensional menu from the vault items
    */
    func createMenu() -> NSMenu {
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
                
                if item.mode == VaultItem.eVaultMode.pasteBoard {
                    newItem?.image = NSImage(named: NSImage.Name(rawValue: "clipboard"))
                }
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let mindvaultMenu = NSMenuItem(title: "Mindvault", action: nil, keyEquivalent: "")
        mindvaultMenu.submenu = NSMenu()
        mindvaultMenu.submenu?.addItem(NSMenuItem(title: "Reload", action: #selector(reloadAction(_:)), keyEquivalent: "r"))
        mindvaultMenu.submenu?.addItem(NSMenuItem(title: "New items", action: #selector(newItemAction(_:)), keyEquivalent: "n"))
        mindvaultMenu.submenu?.addItem(NSMenuItem.separator())
        
        windowsMenu.submenu = NSMenu()
        
        for (key, ow) in openWindows {
            let windowItem = NSMenuItem(title: ow.title, action: #selector(showWindowAction(_:)), keyEquivalent: "")
            windowItem.tag = key
            
            let closeWindowItem = NSMenuItem(title: "close", action: #selector(closeWindowAction(_:)), keyEquivalent: "")
            closeWindowItem.tag = key
            
            windowItem.submenu = NSMenu()
            windowItem.submenu?.addItem(closeWindowItem)
            
            windowsMenu.submenu?.addItem(windowItem)
            
        }

        mindvaultMenu.submenu?.addItem(windowsMenu)

        menu.addItem(mindvaultMenu)
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exitAction(_:)), keyEquivalent: "k"))
        
        return menu
        
    }
    
    func getNumberOfMenuItemsByTitle(title: String, menu: NSMenu) -> Int {
        var result: Int = 0
        for menuItem in (menu.items) {
            if menuItem.title == title {
                result += 1
            }
        }
        return result
    }
    
    func getMenuItem(title: String, menu: NSMenu, searchIndex: Int = 1) -> NSMenuItem? {
        var foundItems: [NSMenuItem] = []

        if menu.items.count > 0 {
            for menuItem in menu.items {
                if menuItem.title == title {
                    foundItems.append(menuItem)
                }
            }
        }
        if foundItems.count > 1 {
            return foundItems[min(foundItems.count - 1, searchIndex - 1)]
        }
        if foundItems.count == 1 {
            return foundItems[0]
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
        case VaultItem.eVaultMode.none, VaultItem.eVaultMode.pasteBoard:
            copyToPasteboard(text: item.value)

        case VaultItem.eVaultMode.dialog:
            NSLog("open tableFile")
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VaultText")) as! VaultTextWindowController
            wc.showWindow(self)
            wc.attachValueItem(item: item)
            NSApp.activate(ignoringOtherApps: true)
            
            addWindowToMenu(title: item.name(), wc: wc)
            
        case VaultItem.eVaultMode.table, VaultItem.eVaultMode.tableFile:
            NSLog("open tableFile")
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VaultTable")) as! VaultTableWindowController
            wc.showWindow(self)
            wc.attachValueItem(item: item)
            NSApp.activate(ignoringOtherApps: true)

            addWindowToMenu(title: item.name(), wc: wc)

        case VaultItem.eVaultMode.howto, VaultItem.eVaultMode.howtoFile:
            NSLog("open howtoFile")
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
            let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VaultHowto")) as! VaultHowtoWindowController
            wc.showWindow(self)
            wc.attachValueItem(item: item)
            NSApp.activate(ignoringOtherApps: true)

            addWindowToMenu(title: item.name(), wc: wc)

        case .pictureFile:
            NSLog("open pictureFile")
        }
    }
    
    func addWindowToMenu(title: String, wc: NSWindowController) {
        
        let windowItem = NSMenuItem(title: title, action: #selector(showWindowAction(_:)), keyEquivalent: "")
        windowItem.tag = openedWindows
        
        let closeWindowItem = NSMenuItem(title: "close", action: #selector(closeWindowAction(_:)), keyEquivalent: "")
        closeWindowItem.tag = openedWindows
        
        windowItem.submenu = NSMenu()
        windowItem.submenu?.addItem(closeWindowItem)

        openWindows[openedWindows] = openedWindow(title: title, wc: wc)
        openedWindows = openedWindows + 1
        windowsMenu.submenu?.insertItem(windowItem, at: 0)
        
    }
    
    func windowWillClose(_ sender: NSWindow, name: String = "") {
        for (key, ow) in openWindows {
            if ow.wc.window == sender {

                for mnuItem in (windowsMenu.submenu?.items)! {
                    if mnuItem.tag == key {
                        openWindows.removeValue(forKey: key)
                        windowsMenu.submenu!.removeItem(mnuItem)
                        
                        return
                        
                    }
                }
            }
        }
    }
    
    @objc func showWindowAction(_ sender: Any?) {
        let menuItem : NSMenuItem = sender as! NSMenuItem
        if let wc: NSWindowController = openWindows[menuItem.tag]!.wc {
            
            wc.showWindow(self)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func closeWindowAction(_ sender: Any?) {
        let menuItem : NSMenuItem = sender as! NSMenuItem
        if let wc: NSWindowController = openWindows[menuItem.tag]!.wc {
            
            wc.close()
        }
    }
    
    @objc func reloadAction(_ sender: Any?) {
        loadVault()
    }
    
    @objc func newItemAction(_ sender: Any?) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let wc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "NewItems")) as! NewVaultItemWindowController
        wc.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
        
        addWindowToMenu(title: "New items", wc: wc)
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

