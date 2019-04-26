//
//  PersistenceDomain.swift
//  Mind Vault
//
//  Created by Michel Roovers on 26/04/2019.
//  Copyright © 2019 Michel Roovers. All rights reserved.
//

import Foundation

struct jsonRect: Codable {
    var origin: jsonPoint = jsonPoint()
    var size: jsonSize = jsonSize()
    
    static func fromNSRect(rect: NSRect) -> jsonRect {
        var newRect: jsonRect = jsonRect()
        
        newRect.origin = jsonPoint.fromNSPoint(point: rect.origin)
        newRect.size = jsonSize.fromNSSize(size: rect.size)
        
        return newRect
    }
    
    func toNSRect() -> NSRect {
        return NSRect(origin: self.origin.toNSPoint(), size: self.size.toNSSize())
    }
}

struct jsonPoint: Codable {
    var x: Float = 0.0
    var y: Float = 0.0
    
    static func fromNSPoint(point: NSPoint) -> jsonPoint {
        var newPoint = jsonPoint()
        
        newPoint.x = Float(point.x)
        newPoint.y = Float(point.y)
        
        return newPoint
    }
    
    func toNSPoint() -> NSPoint {
        return NSPoint(x: CGFloat(self.x), y: CGFloat(self.y))
    }
}

struct jsonSize: Codable {
    var width: Float = 0.0
    var height: Float = 0.0
    
    static func fromNSSize(size: NSSize) -> jsonSize {
        var newSize = jsonSize()
        
        newSize.width = Float(size.width)
        newSize.height = Float(size.height)
        
        return newSize
    }
    
    func toNSSize() -> NSSize {
        return NSSize(width: CGFloat(self.width), height: CGFloat(self.height))
    }
}
