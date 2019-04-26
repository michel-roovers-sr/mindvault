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
    
    override func viewDidAppear() {
        let defaults = UserDefaults.standard
        
        // Retieve window size and position
        let json = defaults.string(forKey: String(format: "%@-window-rect", name))
        if json != nil {
            let decoder = JSONDecoder()
            do {
                let rect = try decoder.decode(jsonRect.self, from: json!.data(using: .utf8)!)
//                NSLog("Window: x: %f, y: %f, width: %f, height: %f", Float(rect.origin.x), Float(rect.origin.y), Float(rect.size.width), Float(rect.size.height))
                
                var newRect = rect.toNSRect()
            
                if fitOnScreen(rect: newRect) {
                    
                    self.view.window?.setFrame(newRect, display: true)
                }
                else {
                    
                    newRect.origin = (self.view.window?.frame.origin)!
                    self.view.window?.setFrame(newRect, display: true)
                }
            }
            catch {
                NSLog("Retrieve window size and position went wrong: %@", error.localizedDescription)
            }
        }
    }
    
    override func viewWillDisappear() {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.windowWillClose(self.view.window!, name: name)
        
        // Store the window's size and position
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let frame: NSRect = self.view.window!.frame
        do {
            
            let rect = jsonRect.fromNSRect(rect: frame)
            let data = try encoder.encode(rect)
            let json = String(data: data, encoding: .utf8)!
//            NSLog(json)
            
            let defaults = UserDefaults.standard
            defaults.set(json, forKey: String(format: "%@-window-rect", name))

        }
        catch {
            NSLog("Store window's size and position went wrong")
        }

        super.viewWillDisappear()
        
    }
    
    func fitOnScreen(rect: NSRect) -> Bool {
        let screen = NSScreen.main
        let visibleRect = screen?.visibleFrame
        
        return visibleRect?.contains(rect.origin) ?? false
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
