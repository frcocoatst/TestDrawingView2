//
//  Element.swift
//  TestDrawing
//
//  Created by Friedrich HAEUPL on 11.05.16.
//  Copyright © 2016 Friedrich HAEUPL. All rights reserved.
//

import Cocoa

struct Element
{
    // description data
    var number:                     Int                     // reference number
    var type:                       Int                     // type = [BUBBLE|TERMINATOR|STORE|RECT]
    var name:                       String                  // name string
    var description:                String                  // description string
    // layout data
    var location:                   NSPoint                 // central location of the element
}