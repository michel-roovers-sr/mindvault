//
//  VaultHowtoViewController.swift
//  Mind Vault
//
//  Created by Michel Roovers on 16/03/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class VaultHowtoViewController: MVViewController, NSComboBoxDelegate {
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
        name = "howto-view"
        super.viewDidLoad()
        // Do view setup here.

        howtoTags.delegate = self
        
    }
    
    override func getFontSize() -> CGFloat {
        return CGFloat(whatText.font?.pointSize ?? 10.0)
    }
    
    override func setFontSize(newSize: CGFloat) {
        let fontname = whatText.font?.fontName
        
        whatText.font = NSFont.init(name: fontname!, size: newSize)
        whyText.font = NSFont.init(name: fontname!, size: newSize)
        howText.font = NSFont.init(name: fontname!, size: newSize)
        
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
    
}
