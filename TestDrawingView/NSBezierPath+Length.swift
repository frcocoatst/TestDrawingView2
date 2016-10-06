//
//  NSBezierPath+Length.swift
//  TestDrawingView
//
//  Created by Friedrich HAEUPL on 11.07.16.
//  Copyright © 2016 Friedrich HAEUPL. All rights reserved.
//

import Cocoa
//import Foundation

extension NSBezierPath {
    
    var lenght:Double {
        get{
            let flattenedPath =  self.flattened
            let segments = flattenedPath.elementCount
            var lastPoint:NSPoint = NSZeroPoint
            var point:NSPoint = NSZeroPoint
            var size :Double = 0
            
            for i in 0...segments - 1 {
                let e:NSBezierPathElement = flattenedPath.element(at: i, associatedPoints: &point)
                
                let currPoint = NSStringFromPoint(point)
                
                switch (e){
                case .moveToBezierPathElement:
                    NSLog("MoveToBezierPathElement %d %@", i, currPoint)
                    break
                    
                case .lineToBezierPathElement:
                    NSLog("LineToBezierPathElement %d %@", i, currPoint)
                    break
                    
                case .curveToBezierPathElement:
                    NSLog("CurveToBezierPathElement %d %@", i, currPoint)
                    break
                    
                case .closePathBezierPathElement:
                    NSLog("ClosePathBezierPathElement %d %@", i, currPoint)
                    break
                }
                /*
                */
                if e == .moveToBezierPathElement {
                    lastPoint = point
                } else {
                    let distance:Double = sqrt(pow(Double(point.x - lastPoint.x) , 2) + pow(Double(point.y - lastPoint.y) , 2))
                    size += distance
                    lastPoint = point
                }
            }
            
            return size
        }
    }
}
