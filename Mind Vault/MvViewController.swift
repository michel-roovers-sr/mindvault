//
//  MvViewController.swift
//  Mind Vault
//
//  Created by Michel Roovers on 12/04/2019.
//  Copyright © 2019 Michel Roovers. All rights reserved.
//

import Cocoa

class MVViewController: NSViewController {

    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        //  get previous and adjust current font size
        let fontsize = Float(getFontSize())
        
        let defaults = UserDefaults.standard
        let prev_size = defaults.float(forKey: "font_size")
        
        let increment = prev_size - fontsize;
        changeFontSize(increment: CGFloat(increment))
        
    }
    
    override func viewWillDisappear() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.windowWillClose(self.view.window!, name: name)
        
        super.viewWillDisappear()
    }

    func getFontSize() -> CGFloat {
        return 10.0
    }
    
    func setFontSize(newSize: CGFloat) {
        // Calls the override function to update the font size of the view
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
        let fontsize = getFontSize()
        if( fontsize + increment > CGFloat(10.0)) {
            setFontSize(newSize: fontsize + increment)
            
            let defaults = UserDefaults.standard
            defaults.set(fontsize + increment, forKey: "font_size")
            
        }
    }

}
