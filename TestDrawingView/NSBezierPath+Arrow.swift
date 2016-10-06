//
//  NSBezierPath+Arrow.swift
//  BezierView
//
//  Created by FH on 15.06.16.
//  Copyright © 2016 FH. All rights reserved.
//
//  from: https://gist.github.com/mwermuth/07825df27ea28f5fc89a


//  also: https://gist.github.com/lukaskubanek/1f3585314903dfc66fc7
//  also: https://github.com/XavierDK/XDKWalkthrough/blob/master/XDKWalkthroughExemple/XDKWalkthrough/UIBezierPath%2BXDKArrow.m


import Cocoa
import Foundation

let kArrowPointCount = 7

extension NSBezierPath {
    /// getAxisAlignedArrowPoints - creates a points array of an arrow
    /// - parameter points:     points array
    /// - parameter forLength:  length
    /// - parameter tailWidth:  tail width
    /// - parameter headWidth:  head width
    /// - parameter headLength: head length
    ///
    class func getAxisAlignedArrowPoints(_ points: inout Array<NSPoint>,
                                               forLength: CGFloat,
                                               tailWidth: CGFloat,
                                               headWidth: CGFloat,
                                               headLength: CGFloat ){
        
        let tailLength = forLength - headLength
        points.append(NSPoint(x: 0, y: tailWidth/2))
        points.append(NSPoint(x: tailLength, y: tailWidth/2))
        points.append(NSPoint(x: tailLength, y: headWidth/2))
        points.append(NSPoint(x: forLength, y: 0))
        points.append(NSPoint(x: tailLength, y: -headWidth/2))
        points.append(NSPoint(x: tailLength, y: -tailWidth/2))
        points.append(NSPoint(x: 0, y: -tailWidth/2))
        
    }
    /// curveFromPointtoPointWithcontrolPoints - creates a bezier curve from startPoint to endPoint with control points 
    /// and an arrow at endPoint using NSAffineTransform for the arrow
    /// - parameter startPoint:     start point
    /// - parameter endPoint:       end point
    /// - parameter controlPoint1:  control point 1
    /// - parameter controlPoint2:  control point 1
    /// - parameter tailWidth:      tail width
    /// - parameter headWidth:      head width
    /// - parameter headLength:     head length
    /// - returns: an NSBezierPath
    class func curveFromPointtoPointWithcontrolPoints(_ startPoint:NSPoint,
                                                      endPoint: NSPoint,
                                                      controlPoint1: NSPoint,
                                                      controlPoint2: NSPoint,
                                                      tailWidth: CGFloat,
                                                      headWidth: CGFloat,
                                                      headLength: CGFloat) -> NSBezierPath {
        
        // Helpful resources
        // http://stackoverflow.com/questions/14068862/drawing-an-arrow-with-nsbezierpath-between-two-points
        // https://gist.github.com/mayoff/4146780
        
        
        let path:NSBezierPath = NSBezierPath()
        
        NSColor.blue.set()
        
        // Arrow length
        let length:CGFloat = CGFloat(hypotf(Float(endPoint.x - controlPoint2.x), Float(endPoint.y - controlPoint2.y)))
        
        // The transformation
        let cosine:CGFloat  = (endPoint.x - controlPoint2.x) / length
        let sine:CGFloat    = (endPoint.y - controlPoint2.y) / length
        
        // Fill NSAffineTransformStruct
        let transformStruct = NSAffineTransformStruct(m11: cosine, m12: sine, m21: -sine, m22: cosine, tX: endPoint.x, tY: endPoint.y)
        
        // Create NSAffineTransform
        let tr = NSAffineTransform()
        
        // Set NSAffineTransformStruct for NSAffineTransform
        tr.transformStruct = transformStruct
        
        // Points array
        var points = [NSPoint]()
        // Get arrow points
        self.getAxisAlignedArrowPoints(&points, forLength: 0, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        
        // create a path with the arrow
        path.move(to: points[0])
        
        for i in 0..<kArrowPointCount{
            path.line(to: points[i])
        }
        
        // apply the transformation
        path.transform(using: tr as AffineTransform)
        // path.closePath() // only frame is shown
        path.fill()
        
        // make the curve
        path.move(to: startPoint)
        path.curve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        return path
        
    }

    /// curveWithArrow - creates a bezier curve from startPoint to endPoint with control points
    /// and an arrow at endPoint using classic math for the arrow
    /// - parameter startPoint:     start point
    /// - parameter endPoint:       end point
    /// - parameter controlPoint1:  control point 1
    /// - parameter controlPoint2:  control point 1
    /// - parameter tailWidth:      tail width
    /// - parameter headWidth:      head width
    /// - parameter headLength:     head length
    /// - returns: an NSBezierPath
    
    class func curveWithArrow(_ startPoint:NSPoint,
                              endPoint:NSPoint,
                              controlPoint1:NSPoint,
                              controlPoint2:NSPoint,
                              tailWidth:CGFloat,
                              headWidth:CGFloat,
                              headLength:CGFloat) -> NSBezierPath {
        
        /*
         stolen from  https://osxentwicklerforum.de/index.php/Thread/5405-Algodingsbums-Pfeilspitze-auf-Rechteck/?postID=54116&highlight=NSAffineTransform#post54116
         
         - Die Länge des Richtungsvektors normieren
         - vom Punkt an der Spitze aus <pfeilspitzenlänge> den Richtungsvektor zurückgehen
         - von dort aus <pfeilspitzenbreite/2> quer gehen ( (y/-x) ist dann ja auch auf Einheitslänge)
         - und das gleiche nochmal in die andere Richtung (-y/x) - fertig!
         */
        
        let path = NSBezierPath()
        
        NSColor.blue.set()
        
        // linie zeichnen
        // path.moveToPoint(controlPoint2)
        // path.lineToPoint(endPoint)
        
        // richtungsvektor berechnen
        var vd:NSPoint = NSPoint()
        vd.x = endPoint.x - controlPoint2.x
        vd.y = endPoint.y - controlPoint2.y
        
        // normieren
        // float len = sqrtf( (vd.x * vd.x) + (vd.y * vd.y) )
        //    vd.x /= len
        //    vd.y /= len
        let len:CGFloat = CGFloat(hypotf(Float(endPoint.x - controlPoint2.x), Float(endPoint.y - controlPoint2.y)))
        vd.x = vd.x/len
        vd.y = vd.y/len
        
        // zurueck gehen
        var triangleBase:NSPoint = NSPoint()
        triangleBase.x = endPoint.x - ( headLength * vd.x)
        triangleBase.y = endPoint.y - ( headLength * vd.y)
        
        // normale
        let tmp:CGFloat = -vd.x
        vd.x = vd.y
        vd.y = tmp
        
        // eckpunkte berechnen
        var pe1:NSPoint = NSPoint()
        pe1.x = triangleBase.x  - ( headWidth * vd.x)
        pe1.y = triangleBase.y  - ( headWidth * vd.y)
        
        var pe2:NSPoint = NSPoint()
        pe2.x = triangleBase.x  + ( headWidth * vd.x)
        pe2.y = triangleBase.y  + ( headWidth * vd.y)
        
        // dreieck malen
        let triangle = NSBezierPath()
        
        triangle.move(to: endPoint)
        triangle.line(to: pe1)
        triangle.line(to: pe2)
        triangle.line(to: endPoint)
        //triangle.closePath()
        triangle.fill()
        
        path.append(triangle)
        
        // make the curve
        // path.lineWidth = tailWidth // funktioniert hier nicht ???
        path.move(to: startPoint)
        path.curve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        return path
    }

} // end of extension
