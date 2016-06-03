//
//  Connection.swift
//  TestDrawing
//
//  Created by Friedrich HAEUPL on 11.05.16.
//  Copyright © 2016 Friedrich HAEUPL. All rights reserved.
//

import Cocoa


struct Connection
{
    // description data
    var number:                     Int                     // reference number
    var type:                       Int                     // type = [DATA|CONTROL]
    var name:                       String                  // name string
    var description:                String                  // description string
    // layout data
    var startPoint_number:          Int                     // reference to the element where the line starts
    var startPoint_connectionPoint: Int                     // reference to the connection point where the line starts
    var endPoint_number:            Int                     // reference to the element where the line ends
    var endPoint_connectionPoint:   Int                     // reference to the connection point where the line ends
    var controlPoint1:              NSPoint                 // control point 1 for beziercurve
    var controlPoint2:              NSPoint                 // control point 2 for beziercurve
    var labelPoint:                 NSPoint                 // point where the label is placed
    
}
