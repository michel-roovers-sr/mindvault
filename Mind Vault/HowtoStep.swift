//
//  HowtoStep.swift
//  Mind Vault
//
//  Created by Michel Roovers on 16/03/2018.
//  Copyright © 2018 Michel Roovers. All rights reserved.
//

import Cocoa

class HowtoStep: NSObject {
    var what : String = ""
    var why : String = ""
    var how : String = ""
    var tag : String = ""
    
    override init() {
    }
    
    static func fromXmlNode(node: XMLNode) -> HowtoStep? {
        var what : String = ""
        var why : String = ""
        var how : String = ""
        var tag : String = ""
        
        for child in node.children! {
            if child.name == "what" {
                what = child.stringValue!
            }
            if child.name == "why" {
                why = child.stringValue!
            }
            if child.name == "how" {
                how = child.stringValue!
            }
            if child.name == "tag" {
                tag = child.stringValue!
            }
        }
        
        if how != "" {
            let result = HowtoStep()
            
            result.what = what
            result.why = why
            result.how = how
            result.tag = tag
            
            return result
            
        }
        
        return nil
        
    }
}
