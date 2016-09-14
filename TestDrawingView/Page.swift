//
//  Page.swift
//  TestDrawingView
//
//  Created by Friedrich HAEUPL on 08.09.16.
//  Copyright © 2016 Friedrich HAEUPL. All rights reserved.
//

//import Foundation
import Cocoa

struct Page
{
    // description data
    var number:                     Int                     // page number
    var type:                       Int                     // type of page = [DFD|DD|...]
    var name:                       String                  // name string of a page
    var description:                String                  // description string of a page
    //
    var number_elements:            Int                     // actual number of elements
    var Elements =                  [Element]()             // [] array of elements
    var number_connections:         Int                     // actual number of connections
    var Connections =               [Connection]()          // [] array of connections
}