//
//  VaultTableViewController.swift
//  Mind Vault
//
//  Created by Michel Roovers on 02/03/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class VaultTableViewController: MVViewController, NSTableViewDataSource, NSTableViewDelegate {

    var vaultItem: VaultItem = VaultItem()
    var fontSize: CGFloat = CGFloat(10.0)
    
    @IBOutlet weak var vaultTableHeader: NSTableHeaderView!
    @IBOutlet weak var vaultTable: NSTableView!
    override func viewDidLoad() {
        name = "table-view"
        super.viewDidLoad()

        //  get previous and adjust current font size
        let defaults = UserDefaults.standard
        let prev_size = defaults.float(forKey: "font_size")
        if prev_size > 0 {
            fontSize = CGFloat(prev_size)
        }
    }
    
    override func getFontSize() -> CGFloat {
        return fontSize
    }
    
    override func setFontSize(newSize: CGFloat) {
        let increment = newSize - fontSize
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
    
}
