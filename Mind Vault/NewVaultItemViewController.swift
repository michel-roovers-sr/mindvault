//
//  NewVaultItemViewController.swift
//  Mind Vault
//
//  Created by Michel Roovers on 27/04/2019.
//  Copyright © 2019 Michel Roovers. All rights reserved.
//

import Cocoa

class NewVaultItemViewController: MVViewController {

    @IBAction func Pasteboard_clicked(_ sender: Any) {
        definitionToPasteboard(index: 0)
    }
    
    @IBAction func Text_clicked(_ sender: Any) {
        definitionToPasteboard(index: 1)
    }
    
    @IBAction func Table_clicked(_ sender: Any) {
        definitionToPasteboard(index: 2)
    }
    
    @IBAction func Howto_clicked(_ sender: Any) {
        definitionToPasteboard(index: 3)
    }
    
    @IBAction func TableFileItem_clicked(_ sender: Any) {
        definitionToPasteboard(index: 4)
    }
    
    @IBAction func HowtoFileItem_clicked(_ sender: Any) {
        definitionToPasteboard(index: 5)
    }
    
    @IBAction func PastboardFile_clicked(_ sender: Any) {
        definitionToPasteboard(index: 6)
    }
    
    @IBAction func TextFile_clicked(_ sender: Any) {
        definitionToPasteboard(index: 7)
    }
    
    @IBAction func TableFile_clicked(_ sender: Any) {
        definitionToPasteboard(index: 8)
    }
    
    @IBAction func HowtoFile_clicked(_ sender: Any) {
        definitionToPasteboard(index: 9)
    }
    
    func definitionToPasteboard(index: Int) {
        if index < VaultItem.itemDefinitions.count {
            
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()

            let text = VaultItem.itemDefinitions[index]
            pasteboard.setString(text!, forType: NSPasteboard.PasteboardType.string)

        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        name = "new-items"

    }
    
}
