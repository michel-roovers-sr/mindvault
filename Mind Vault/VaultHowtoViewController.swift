//
//  VaultHowtoViewController.swift
//  Mind Vault
//
//  Created by Michel Roovers on 16/03/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class VaultHowtoViewController: NSViewController, NSComboBoxDelegate {
    var vaultItem: VaultItem = VaultItem()
    var step: Int = 1
    var minStep = 1
    var maxStep = 0
    
    @IBOutlet weak var currentStep: NSTextField!
    
    @IBOutlet var whatText: NSTextView!
    
    @IBOutlet var whyText: NSTextView!
    
    @IBOutlet var howText: NSTextView!

    @IBOutlet weak var howtoTags: NSComboBox!
    
    @IBAction func NextClicked(_ sender: Any) {
        if step < maxStep {
            step += 1
            howtoTags.selectItem(at: step - 1)
        }
    }
    
    @IBAction func LastClicked(_ sender: Any) {
        step = maxStep
        howtoTags.selectItem(at: step - 1)
    }
    
    @IBAction func FirstClicked(_ sender: Any) {
        step = minStep
        howtoTags.selectItem(at: step - 1)
    }
    
    @IBAction func PreviousClicked(_ sender: Any) {
        if step > minStep {
            step -= 1
            howtoTags.selectItem(at: step - 1)
        }
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        step = self.howtoTags.indexOfSelectedItem + 1
        showStep()

    }
    public func comboBoxWillPopUp(_ notification: Notification) {
        // add implementation here
    }
    
    public func comboBoxWillDismiss(_ notification: Notification) {
        // add implementation here

    }
    
    public func comboBoxSelectionIsChanging(_ notification: Notification) {
        // add implementation here

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) {
            self.keyDown(with: $0)
            return $0
        }

        howtoTags.delegate = self
        
    }
    
    func showStep() {
        currentStep.stringValue = String(format: "%d of %d", self.step, maxStep)
        
        if let howto = vaultItem.getStep(step: step - 1) {
            whatText.string = howto.what
            whyText.string = howto.why
            howText.string = howto.how
        }

    }
    
    func attachVaultItem(item: VaultItem) {
        vaultItem = item
        maxStep = vaultItem.numberOfSteps()
//        showStep()

        howtoTags.addItems(withObjectValues: vaultItem.howtoTags())
        howtoTags.selectItem(at: 0)
        
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
        let fontsize = whatText.font?.pointSize
        if( fontsize! + increment > CGFloat(10.0)) {
            let fontname = whatText.font?.fontName
            
            whatText.font = NSFont.init(name: fontname!, size: fontsize! + increment)
            whyText.font = NSFont.init(name: fontname!, size: fontsize! + increment)
            howText.font = NSFont.init(name: fontname!, size: fontsize! + increment)
            
        }
    }

}
