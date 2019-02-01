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
        
        //  get previous and adjust current font size
        let fontsize = Float(vaultText.font?.pointSize ?? 10.0)
        
        let defaults = UserDefaults.standard
        let prev_size = defaults.float(forKey: "font_size")
        
        let increment = prev_size - fontsize;
        changeFontSize(increment: CGFloat(increment))

    }
    
    func attachVaultItem(item: VaultItem) {
        vaultItem = item
        vaultText.string = vaultItem.value
        
    }
    
    override func viewWillDisappear() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.windowWillClose(self.view.window!)
        
        super.viewWillDisappear()
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
        let fontsize = vaultText.font?.pointSize
        if( fontsize! + increment > CGFloat(10.0)) {
            vaultText.font = NSFont.init(name: (vaultText.font?.fontName)!, size: fontsize! + increment)
            
            let defaults = UserDefaults.standard
            defaults.set(fontsize! + increment, forKey: "font_size")
            
       }
    }

}
