//
//  VaultTableViewController.swift
//  Mind Vault
//
//  Created by Michel Roovers on 02/03/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class VaultTableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vaultItem: VaultItem = VaultItem()
    var fontSize: CGFloat = CGFloat(10.0)
    
    @IBOutlet weak var vaultTableHeader: NSTableHeaderView!
    @IBOutlet weak var vaultTable: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        //  get previous and adjust current font size
        let defaults = UserDefaults.standard
        let prev_size = defaults.float(forKey: "font_size")
        if prev_size > 0 {
            fontSize = CGFloat(prev_size)
        }
    }
    
    func attachVaultItem(item: VaultItem) {
        vaultItem = item
        for elem in item.headerElements() {
            let newColumn = NSTableColumn()
            newColumn.headerCell = NSTableHeaderCell(textCell: elem)
            vaultTable.addTableColumn(newColumn)
            
        }
        
        vaultTable.delegate = self
        vaultTable.dataSource = self
        
        vaultTable.removeTableColumn(vaultTable.tableColumns[0])
        
        vaultTable.reloadData()

    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return vaultItem.numberOfRows()
        
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if vaultItem.data.isEmpty {
            vaultItem.setData()
        }
        
        let cell = NSTextView ()
        cell.backgroundColor = NSColor.clear
        cell.font = NSFont.init(name: (cell.font!.fontName), size: (fontSize))

        let col = tableView.tableColumns.index(of: tableColumn!)
        if col! < (vaultItem.data[row]?.count)! {
            cell.string = vaultItem.data[row]![col!]
        }
        
        return cell
        
    }
    
    override func keyDown(with event: NSEvent) {
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
        for column in 0..<vaultTable.numberOfColumns {
            for row in (0..<vaultTable.numberOfRows) {
                let view = vaultTable.view(atColumn: column, row: row, makeIfNecessary: false) as! NSTextView
                let fontsize = view.font?.pointSize
                let fontname = view.font?.fontName
                if(fontsize! + increment > CGFloat(10.0)) {
                    fontSize = fontsize! + increment
                    view.font = NSFont.init(name: (fontname)!, size: fontSize)
                    view.sizeToFit()

                }
            }
            
            let defaults = UserDefaults.standard
            defaults.set(fontSize, forKey: "font_size")
            
            let rowHeight = vaultTable.rowHeight
            if(rowHeight + increment > CGFloat(17.0)) {
                vaultTable.rowHeight = rowHeight + increment
            }
        }
    }
    
}
