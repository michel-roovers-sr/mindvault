//
//  VaultTextViewController.swift
//  Mind Vault
//
//  Created by Michel Roovers on 02/03/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class VaultTextViewController: MVViewController {

    @IBOutlet var vaultText: NSTextView!
    var vaultItem : VaultItem = VaultItem()
    
    override func viewDidLoad() {
        name = "text-view"
        super.viewDidLoad()
        
    }

    override func getFontSize() -> CGFloat{
        return CGFloat(vaultText.font?.pointSize ?? 10.0)
    }
    
    override func setFontSize(newSize: CGFloat) {
        vaultText.font = NSFont.init(name: (vaultText.font?.fontName)!, size: newSize)

    }
    
    func attachVaultItem(item: VaultItem) {
        vaultItem = item
        vaultText.string = vaultItem.value
        
    }
    
}
