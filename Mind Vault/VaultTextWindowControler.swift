//
//  VaultTextWindowControler.swift
//  Mind Vault
//
//  Created by Michel Roovers on 28/02/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class VaultTextWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
    }
    
    func attachValueItem(item : VaultItem) {
        let vc = contentViewController
        (vc as! VaultTextViewController).attachVaultItem(item: item)
    }
    
}
