//
//  VaultTextViewController.swift
//  Mind Vault
//
//  Created by Michel Roovers on 02/03/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class VaultTextViewController: NSViewController {

    @IBOutlet var vaultText: NSTextView!
    var vaultItem : VaultItem = VaultItem()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.flagsChanged) {
//            self.flagsChanged(with: $0)
//            return $0
//        }
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }
    
    func attachVaultItem(item: VaultItem) {
        vaultItem = item
        vaultText.string = vaultItem.value
        
    }
    
    override func keyDown(with event: NSEvent)
    {
        if UInt(event.modifierFlags.rawValue) & UInt(NSEvent.ModifierFlags.command.rawValue) == UInt(NSEvent.ModifierFlags.command.rawValue) {
            if( event.keyCode == 69 || event.keyCode == 24 ){
                // <command> + <+>
                changeFontSize(increment: 1.0)
            }
            if( event.keyCode == 78 || event.keyCode == 27 ){
                // <command> + <->
                changeFontSize(increment: -1.0)
            }
        }
    }

    func changeFontSize(increment: CGFloat)
    {
        if( (vaultText.font?.pointSize)! + increment > CGFloat(10.0)) {
            vaultText.font = NSFont.init(name: (vaultText.font?.fontName)!, size: (vaultText.font?.pointSize)! + increment)
        }
    }

}
