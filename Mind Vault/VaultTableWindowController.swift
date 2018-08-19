//
//  VaultTableWindoController.swift
//  Mind Vault
//
//  Created by Michel Roovers on 02/03/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class VaultTableWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func attachValueItem(item: VaultItem) {
        let vc = contentViewController
        (vc as! VaultTableViewController).attachVaultItem(item: item)

    }
    
}
