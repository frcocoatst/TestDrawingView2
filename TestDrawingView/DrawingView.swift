//
//  DrawingView.swift
//  TestDrawingView
//
//  Created by Friedrich HAEUPL on 11.05.16.
//  Copyright © 2016 Friedrich HAEUPL. All rights reserved.
//

import Cocoa
import Foundation


let WIDTH:CGFloat = 80
let HEIGHT:CGFloat = 30
let RADIUS:CGFloat = 50
let CONNRADIUS:CGFloat = 5
let SELECTRADIUS:CGFloat = 20
let STOREHEIGHT:CGFloat = 40
let STOREWIDTH :CGFloat = 60

let TRACK_RADIUS:Int = 100
let GRID_RADIUS:Int = 120

var selectedTool:Int = 0
var selected_element_index = -1
var selected_connector_index = -1

var showConnectionPoints:Bool = false


let TYPE_BUBBLE     = 1
let TYPE_TERMINATOR = 2
let TYPE_STORE      = 3
let CONNECT         = 4
let TYPE_STATE      = 5
let TYPE_INPUT      = 6

/// DrawingView - subclass of NSView
///
///
class DrawingView: NSView{
    
    
    // create an array of Element
    var Elements = [Element]()
    var ElementCounter = 0
    
    var Connections = [Connection]()
    var ConnectionCounter = 0
    
    var controlpoint1_selected:Bool = false
    var controlpoint2_selected:Bool = false
    
    //var referenceToDraw:NSAttributedString
    var zoomfactor:CGFloat = 1.0
    
    // initialize
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    // blow up contentsize
    override var intrinsicContentSize: NSSize {
        
        
        NSLog("Zoom = %f intrinsicContentSize = %f %f",zoomfactor, 3000.0*zoomfactor, 2000.0*zoomfactor)
        // tbd.: Fehler bei 0.5
        return NSMakeSize(3000.0*zoomfactor, 2000.0*zoomfactor)
    }
    
    // drawRect
    
    override func drawRect(dirtyRect: NSRect)
    {
        NSColor.whiteColor().setFill()
        NSRectFill(self.bounds)
        //
        super.drawRect(dirtyRect)
        //
        self.drawAllElements()
    }
    
    
    func testPointInRect(point: NSPoint)->Bool {
        return false
        
    }
    
    func setBubbleOrConnectorName(text: NSString){
        NSLog("setBubbleOrConnectorName = %@",text)
        
    }
    
    func setViewSize(value:Double)
    {
        NSLog("setViewSize = %f",value)
        //[self resetScaling]; is:
        //      static const NSSize unitSize = {1.0, 1.0};
        //      NSSize unitSize = {1.0, 1.0}
        //      [self scaleUnitSquareToSize:[self convertSize:unitSize fromView:nil]];
        
        // ????? self.scaleUnitSquareToSize (self.convertSize(NSMakeSize(CGFloat(1.0), CGFloat(1.0)), fromView:nil)
        // First, match our scaling to the window's coordinate system
        //[self scaleUnitSquareToSize:NSMakeSize(value, value)];
        self.scaleUnitSquareToSize (NSMakeSize(CGFloat(value), CGFloat(value)))
        zoomfactor = CGFloat(value)
        
        // Then, set the scale.
        
        // Important, changing the scale doesn't invalidate the display
        //[self setNeedsDisplay:YES];
        needsDisplay = true
    }
    
    func setSelectedTool(tool:Int)
    {
        NSLog("setSelectedTool in DrawingView with tool: %d",tool)
        //   ARROW_TOOL,BUBBLE_TOOL,TERMINATOR_TOOL,STORE_TOOL,CONNECT_TOOL,DOT_TOOL,DELETE_TOOL
        selectedTool = tool
        NSLog("selectedTool = %d",selectedTool)
        
        // clear all selections
        selected_element_index             = -1
        selected_connector_index           = -1
        
        // if selectedTool == ARROW_TOOL || selectedTool == CONNECT_TOOL
        if selectedTool == CONNECT_TOOL
        {
            showConnectionPoints=true
        }
        else
        {
            showConnectionPoints=false
        }
        needsDisplay = true
    }
    

    
    func snapToGrid(clickPoint:NSPoint) -> NSPoint{
        //var snapPoint:NSPoint
        var x:Int
        var y:Int
    
        x = (Int(clickPoint.x) + GRID_RADIUS/2)/GRID_RADIUS
        y = (Int(clickPoint.y) + GRID_RADIUS/2)/GRID_RADIUS
        
        if x==0
        {
            x=1
        }
        if y==0
        {
            y=1
        }
        
        return NSPoint(x:CGFloat(x * GRID_RADIUS), y:CGFloat(y * GRID_RADIUS))
        //
    }
    
    
    
    /// addABubble - adds a bubble at a certain location
    /// - parameter atPoint: point where to add
    ///
    func addABubble(atPoint:NSPoint)
    {
        let π = M_PI
        // snap to grid
        let snapedmousePoint:NSPoint = self.snapToGrid(atPoint)
        
        //NSLog("snapedmousePoint %f %f",snapedmousePoint.x, snapedmousePoint.y)
        
        // add connection points to cPoints array
        var cPoints = [NSPoint]()
        var actualPoint:NSPoint = NSMakePoint(0.0, 0.0)
        
        // generate the connection points
        for i in 0..<12 {
            actualPoint.x = (RADIUS * sin(CGFloat(i) * CGFloat(π) * CGFloat(30.0/180.0)))
            actualPoint.y = (RADIUS * cos(CGFloat(i) * CGFloat(π) * CGFloat(30.0/180.0)))
            cPoints.append(actualPoint)
        }
        // append a new element to the Elements array
        Elements.append(Element(number: ElementCounter,
            type: TYPE_BUBBLE,
            name: "short name",
            description: "long bubble description",
            location: snapedmousePoint,
            number_connectionPoint: 12,
            connectionPoints: cPoints))
        // increase counter
        ElementCounter += 1
    }
    
    /// addASquare - adds a square at a certain location
    /// - parameter atPoint: point where to add
    ///
    func addASquare(atPoint:NSPoint)
    {
        // snap to grid
        let snapedmousePoint:NSPoint = self.snapToGrid(atPoint)
        
        // NSLog("snapedmousePoint %f %f",snapedmousePoint.x, snapedmousePoint.y)
        
        // add connection points to cPoints array
        var cPoints = [NSPoint]()
        var actualPoint:NSPoint = NSMakePoint(0.0, 0.0)

        
        actualPoint.x = 0.0
        actualPoint.y = RADIUS
        cPoints.append(actualPoint)
        
        actualPoint.x = RADIUS/2
        actualPoint.y = RADIUS
        cPoints.append(actualPoint)
        
        actualPoint.x = -RADIUS/2
        actualPoint.y =  RADIUS
        cPoints.append(actualPoint)
        
        actualPoint.x =  RADIUS
        actualPoint.y =  RADIUS/2
        cPoints.append(actualPoint)
        
        actualPoint.x =  RADIUS
        actualPoint.y =  0.0
        cPoints.append(actualPoint)
        
        actualPoint.x =  RADIUS
        actualPoint.y = -RADIUS/2
        cPoints.append(actualPoint)
        
        actualPoint.x = -RADIUS/2
        actualPoint.y = -RADIUS
        cPoints.append(actualPoint)
        
        actualPoint.x = 0.0
        actualPoint.y = -RADIUS
        cPoints.append(actualPoint)
        
        actualPoint.x =  RADIUS/2
        actualPoint.y = -RADIUS
        cPoints.append(actualPoint)
        
        actualPoint.x = -RADIUS
        actualPoint.y = RADIUS/2
        cPoints.append(actualPoint)
        
        actualPoint.x = -RADIUS
        actualPoint.y = 0.0
        cPoints.append(actualPoint)
        
        actualPoint.x =  -RADIUS
        actualPoint.y =  -RADIUS/2
        cPoints.append(actualPoint)
        
        // append a new element to the Elements array
        Elements.append(Element(number: ElementCounter,
            type: TYPE_TERMINATOR,
            name: "short name",
            description: "long terminator description",
            location: snapedmousePoint,
            number_connectionPoint: 12,
            connectionPoints: cPoints))
        
        ElementCounter += 1
    }
    
    /// addAStore - adds a store at a certain location
    /// - parameter atPoint: point where to add
    ///
    func addAStore(atPoint:NSPoint)
    {
        // snap to grid
        let snapedmousePoint:NSPoint = self.snapToGrid(atPoint)
        
        NSLog("snapedmousePoint %f %f",snapedmousePoint.x, snapedmousePoint.y)

        // add connection points to cPoints array
        var cPoints = [NSPoint]()
        var actualPoint:NSPoint = NSMakePoint(0.0, 0.0)
        
        actualPoint.x = 0.0
        actualPoint.y = STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x = STOREWIDTH/2
        actualPoint.y = STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x = -STOREWIDTH/2
        actualPoint.y =  STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x = -STOREWIDTH
        actualPoint.y =  STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x =  STOREWIDTH
        actualPoint.y =  STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x = -STOREWIDTH/2
        actualPoint.y = -STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x =  0.0
        actualPoint.y = -STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x =  STOREWIDTH/2
        actualPoint.y = -STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x = -STOREWIDTH
        actualPoint.y = -STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x =  STOREWIDTH
        actualPoint.y = -STOREHEIGHT
        cPoints.append(actualPoint)
        
        
        Elements.append(Element(number: ElementCounter,
            type: TYPE_STORE,
            name: "short name",
            description: "long store description",
            location: snapedmousePoint,
            number_connectionPoint: 10,
            connectionPoints: cPoints))
        
        ElementCounter += 1
    }
    
    /// addAInput - adds a input at a certain location
    /// - parameter atPoint: point where to add
    ///
    func addAInput(atPoint:NSPoint)
    {
        let π = M_PI
        let snapedmousePoint:NSPoint = self.snapToGrid(atPoint)
        
        NSLog("snapedmousePoint %f %f",snapedmousePoint.x, snapedmousePoint.y)
        
        var cPoints = [NSPoint]()
        var actualPoint:NSPoint = NSMakePoint(0.0, 0.0)
        
        for i in 0..<6 {
            actualPoint.x = (2*CONNRADIUS * sin(CGFloat(i) * CGFloat(π) * CGFloat(60.0/180.0)))
            actualPoint.y = (2*CONNRADIUS * cos(CGFloat(i) * CGFloat(π) * CGFloat(60.0/180.0)))
            cPoints.append(actualPoint)
        }
        
        Elements.append(Element(number: ElementCounter,
            type: TYPE_INPUT,
            name: "short name",
            description: "long input description",
            location: snapedmousePoint,
            number_connectionPoint: 6,
            connectionPoints: cPoints))
        
        ElementCounter += 1
    }
    
    /// addAState - adds a state at a certain location
    /// - parameter atPoint: point where to add
    ///
    func addAState(atPoint:NSPoint)
    {
        let snapedmousePoint:NSPoint = self.snapToGrid(atPoint)
        
        NSLog("snapedmousePoint %f %f",snapedmousePoint.x, snapedmousePoint.y)
        
        // add connection points to cPoints array
        var cPoints = [NSPoint]()
        var actualPoint:NSPoint = NSMakePoint(0.0, 0.0)
        
        actualPoint.x = 0.0
        actualPoint.y = STOREHEIGHT
        cPoints.append(actualPoint)
        actualPoint.x = 0.0
        actualPoint.y = STOREHEIGHT/4
        cPoints.append(actualPoint)
        actualPoint.x = 0.0
        actualPoint.y = STOREHEIGHT/2
        cPoints.append(actualPoint)
        actualPoint.x = 0.0
        actualPoint.y = STOREHEIGHT*3/4
        cPoints.append(actualPoint)
        actualPoint.x = 0.0
        actualPoint.y = 0.0
        cPoints.append(actualPoint)
        actualPoint.x = 0.0
        actualPoint.y = -STOREHEIGHT*3/4
        cPoints.append(actualPoint)
        actualPoint.x = 0.0
        actualPoint.y = -STOREHEIGHT/2
        cPoints.append(actualPoint)
        actualPoint.x = 0.0
        actualPoint.y = -STOREHEIGHT/4
        cPoints.append(actualPoint)
        actualPoint.x = 0.0
        actualPoint.y = -STOREHEIGHT
        cPoints.append(actualPoint)

        
        Elements.append(Element(number: ElementCounter,
            type: TYPE_STATE,
            name: "short name",
            description: "long bubble description",
            location: snapedmousePoint,
            number_connectionPoint: 12,
            connectionPoints: cPoints))
        
        ElementCounter += 1
    }
    
    func drawAllElements()
    {
        let path = NSBezierPath()
        let apath = NSBezierPath()
        
        // selected_element_index = 2  // change this done in testSelectElementInRect
        
        for (index,e) in Elements.enumerate(){
            
            //NSLog("drawAllElements: index=%d",index)
            
            // ------ is it a selected element ? ------
            
            if ((selected_element_index != -1) && (selected_element_index == index))
            {
                NSColor.redColor().set()
                path.lineWidth = 5.0
            }
            else
            {
                NSColor.blackColor().set()
                path.lineWidth = 2.0
            }
            
            // draw various variants of the element
            if e.type == TYPE_BUBBLE
            {
                // clear the path
                path.removeAllPoints()
                
                // ------ draw the circle ------
                let rect = NSRect(x: e.location.x - RADIUS,
                                  y: e.location.y - RADIUS,
                                  width: 2*RADIUS,
                                  height: 2*RADIUS)
                
                path.appendBezierPathWithOvalInRect(rect)
                
                path.stroke()
                
                // ------ draw text into the circle ------
                // let text: NSString = e.name + " \(e.number)"//+ e.description
                // build a long string with linebreaks
                let text: NSString = e.name + String("\n") + String(format:"%d", e.number) + String(format:"(%d)", index) + String("\n") + e.description
                
                let font = NSFont(name: "Menlo", size: 10.0)
                
                let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                textStyle.alignment = NSTextAlignment.Center
                textStyle.lineHeightMultiple = 1.2
                textStyle.lineBreakMode = .ByWordWrapping
                
                //let textColor = NSColor(calibratedRed: 0.147, green: 0.222, blue: 0.162, alpha: 1.0)
                let textColor = NSColor.blueColor()
                
                let textFontAttributes = [
                    NSFontAttributeName : font!,
                    NSForegroundColorAttributeName: textColor,
                    NSParagraphStyleAttributeName: textStyle
                ]
                text.drawInRect(NSOffsetRect(rect, 0, -10), withAttributes: textFontAttributes)
                
            }
            else if e.type == TYPE_TERMINATOR
            {
                // clear the path
                path.removeAllPoints()
                
                // ------ draw a rectangle ------
                let rect = NSRect(x: e.location.x - RADIUS,
                                  y: e.location.y - RADIUS,
                                  width: 2*RADIUS,
                                  height: 2*RADIUS)
                
                path.appendBezierPathWithRect(rect)
                
                path.stroke()
                
                // ------ draw text into the square ------
                // let text: NSString = e.name + " \(e.number)"//+ e.description
                // build a long string with linebreaks
                let text: NSString = e.name + String("\n") + String(format:"%d", e.number) + String(format:"(%d)", index) + String("\n") + e.description
                
                let font = NSFont(name: "Menlo", size: 10.0)
                
                let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                textStyle.alignment = NSTextAlignment.Center
                textStyle.lineHeightMultiple = 1.2
                textStyle.lineBreakMode = .ByWordWrapping
                
                //let textColor = NSColor(calibratedRed: 0.147, green: 0.222, blue: 0.162, alpha: 1.0)
                let textColor = NSColor.blueColor()
                
                let textFontAttributes = [
                    NSFontAttributeName : font!,
                    NSForegroundColorAttributeName: textColor,
                    NSParagraphStyleAttributeName: textStyle
                ]
                text.drawInRect(NSOffsetRect(rect, 0, -10), withAttributes: textFontAttributes)
                
            }
            else if e.type == TYPE_STORE
            {
                // clear the path
                path.removeAllPoints()
                
                // ------ draw two horizontal bars ------
                let rect = NSRect(x: e.location.x - STOREWIDTH,
                                  y: e.location.y - STOREHEIGHT,
                                  width: 2*STOREWIDTH,
                                  height: 2*STOREHEIGHT)
                
                let p1:NSPoint = NSMakePoint(rect.origin.x,                     rect.origin.y + rect.size.height)
                let p2:NSPoint = NSMakePoint(rect.origin.x + rect.size.width,   rect.origin.y + rect.size.height)
                let p3:NSPoint = NSMakePoint(rect.origin.x,                     rect.origin.y)
                let p4:NSPoint = NSMakePoint(rect.origin.x + rect.size.width,   rect.origin.y )
                
                path.moveToPoint(p1)
                path.lineToPoint(p2)
                path.moveToPoint(p3)
                path.lineToPoint(p4)
                
                path.stroke()
                
                // ------ draw text between the two bars ------
                // let text: NSString = e.name + " \(e.number)"//+ e.description
                // build a long string with linebreaks
                let text: NSString = e.name + String("\n") + String(format:"%d", e.number) + String(format:"(%d)", index) + String("\n") + e.description
                
                let font = NSFont(name: "Menlo", size: 10.0)
                
                let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                textStyle.alignment = NSTextAlignment.Center
                textStyle.lineHeightMultiple = 1.2
                textStyle.lineBreakMode = .ByWordWrapping
                
                //let textColor = NSColor(calibratedRed: 0.147, green: 0.222, blue: 0.162, alpha: 1.0)
                let textColor = NSColor.blueColor()
                
                let textFontAttributes = [
                    NSFontAttributeName : font!,
                    NSForegroundColorAttributeName: textColor,
                    NSParagraphStyleAttributeName: textStyle
                ]
                text.drawInRect(NSOffsetRect(rect, 0, -10), withAttributes: textFontAttributes)
                
            }
            else if e.type == TYPE_STATE
            {
                // clear the path
                path.removeAllPoints()
                
                // ------ draw two horizontal bars ------
                let rect = NSRect(x: e.location.x,
                                  y: e.location.y - STOREHEIGHT,
                                  width: 2,
                                  height: 2*STOREHEIGHT)
                
                //let p1:NSPoint = NSMakePoint(rect.origin.x,                     rect.origin.y + rect.size.height)
                let p2:NSPoint = NSMakePoint(rect.origin.x,   rect.origin.y + rect.size.height)
                //let p3:NSPoint = NSMakePoint(rect.origin.x,                     rect.origin.y)
                let p4:NSPoint = NSMakePoint(rect.origin.x,   rect.origin.y )
                
                path.moveToPoint(p2)
                path.lineToPoint(p4)
                
                path.stroke()

                // ------ draw text  ------
                // tbd
                // let text: NSString = e.name + String("\n") + String(format:"%d", e.number) + String(format:"(%d)", index) + String("\n") + e.description

                
                
            }
            else if e.type == TYPE_INPUT
            {
                // clear the path
                path.removeAllPoints()
                
                // ------ draw the circle ------
                let rect = NSRect(x: e.location.x - 2*CONNRADIUS,
                                  y: e.location.y - 2*CONNRADIUS,
                                  width: 4*CONNRADIUS,
                                  height:4*CONNRADIUS)
                
                path.appendBezierPathWithOvalInRect(rect)
                
                path.stroke()
                
                
            }
            
            // ------ draw all connection points ------
            if showConnectionPoints==true
            {
                apath.removeAllPoints()
                
                for c in e.connectionPoints
                {
                    NSColor.blueColor().set()
                    let dotRect = NSRect(x: e.location.x + c.x - CONNRADIUS,
                                         y: e.location.y + c.y - CONNRADIUS,
                                         width: 2*CONNRADIUS,
                                         height: 2*CONNRADIUS)
                    
                    apath.appendBezierPathWithOvalInRect(dotRect)
                    apath.lineWidth = 1
                    apath.stroke()
                }
            }
            
            
            //NSLog("number = %d",e.number)
        }
    }
    
    // -----------------
    
    /* draw a bubble
     -(void)drawABubble:(int)index
     {
     NSRect dotRect;
     NSBezierPath *path;
     NSBezierPath *apath;
     NSPoint center;
     int j;
     float radius=RADIUS;
     
     center = arrayOfElements[index].location;
     // ------ draw the circle
     dotRect.origin.x    = center.x - RADIUS;
     dotRect.origin.y    = center.y - RADIUS;
     dotRect.size.width  = 2*RADIUS;
     dotRect.size.height = 2*RADIUS;
     
     if ((selected_element_index != -1) && (selected_element_index == index))
     {
     [[NSColor redColor] set];
     path = [NSBezierPath bezierPathWithOvalInRect:dotRect];
     [path setLineWidth:5.0];
     }
     else
     {
     [[NSColor blackColor] set];
     path = [NSBezierPath bezierPathWithOvalInRect:dotRect];
     [path setLineWidth:linewidth];
     }
     [path stroke];
     
     // ------ draw string into bubble
     sprintf(arrayOfElements[index].name,"0.%d",index);
     NSString *str = [[NSString alloc]initWithBytes:arrayOfElements[index].name length:sizeof(arrayOfElements[index].name) encoding:NSUTF8StringEncoding];
     
     NSAttributedString* referenceToDraw = [[NSAttributedString alloc] initWithString:str attributes:STRING_ATTR];
     
     // figure out how big the string is going to be so we can center it
     NSSize referenceSize = [referenceToDraw size];
     
     // figure out where to draw the reference in the upper quater of the circle.
     NSPoint referencePoint = NSMakePoint(dotRect.origin.x + (dotRect.size.width - referenceSize.width)/2,
     (dotRect.origin.y + (dotRect.size.height - referenceSize.height - radius/4)));
     
     // draw the string
     [referenceToDraw drawAtPoint:referencePoint];
     
     // draw string into bubble
     // create the string
     NSString *strdesc = [[NSString alloc]initWithBytes:arrayOfElements[index].description length:sizeof(arrayOfElements[index].description) encoding:NSUTF8StringEncoding];
     
     NSAttributedString* stringToDraw = [[NSAttributedString alloc] initWithString:strdesc attributes:STRING_ATTR];
     
     // figure out how big the string is going to be so we can center it
     NSSize stringSize = [stringToDraw size];
     
     // figure out where to draw the string.  Centered in the circle.
     NSPoint destPoint = NSMakePoint(dotRect.origin.x + (dotRect.size.width - stringSize.width)/2,
     (dotRect.origin.y + (dotRect.size.height - stringSize.height)/2));
     
     // draw the string
     [stringToDraw drawAtPoint:destPoint];
     
     
     // ------ connection points
     NSPoint conn;
     for(j=0; j<arrayOfElements[index].number_connectionPoint; j++)
     {
     conn.x = arrayOfElements[index].connectionPoints[j].x;
     conn.y = arrayOfElements[index].connectionPoints[j].y;
     // -------------- Circle --------------
     dotRect.origin.x = conn.x - CONNRADIUS;
     dotRect.origin.y = conn.y - CONNRADIUS;
     dotRect.size.width  = 2 * CONNRADIUS;
     dotRect.size.height = 2 * CONNRADIUS;
     
     if (showConnectionPoints==YES)
     {
     [[NSColor blueColor] set];
     apath = [NSBezierPath bezierPathWithOvalInRect:dotRect];
     [apath setLineWidth:1];
     [apath stroke];
     }
     }
     }
     
     */
    
    
    func testSelectElementInRect(point:NSPoint) -> Bool{
        
        for (index,e) in Elements.enumerate(){
            let aRect = NSRect(x: e.location.x - RADIUS,
                              y: e.location.y - RADIUS,
                              width: 2*RADIUS,
                              height: 2*RADIUS)
            
            if NSPointInRect(point, aRect){
                selected_element_index = index
                NSLog("selected_element_index =%d",selected_element_index)
                return true
            }
       
        }
        return false
    }
    
    func testControlPointSelected(point:NSPoint) -> Bool{
        
        // security check
        if (selected_connector_index == -1)
        {
            return false
        }
        
        
        // get the controlpoints
        let controlPoint_1 : NSPoint = Connections[selected_connector_index].controlPoint1
        let controlPoint_2 : NSPoint = Connections[selected_connector_index].controlPoint2
        
        // test if controlpoint1 is selected
        let aRect = NSRect(x: controlPoint_1.x - SELECTRADIUS,
                           y: controlPoint_1.y - SELECTRADIUS,
                           width:  2*SELECTRADIUS,
                           height: 2*SELECTRADIUS)
        
        if NSPointInRect(point, aRect){
            controlpoint1_selected = true
            NSLog("controlpoint1_selected")
            return true
        }
        
        // test if controlpoint2 is selected
        let bRect = NSRect(x: controlPoint_2.x - SELECTRADIUS,
                           y: controlPoint_2.y - SELECTRADIUS,
                           width:  2*SELECTRADIUS,
                           height: 2*SELECTRADIUS)
        
        if NSPointInRect(point, bRect){
            controlpoint2_selected = true
            NSLog("controlpoint2_selected")
            return true
        }
        return false
    }
    
    func testSelectConnectorInRect(point:NSPoint) -> Bool{
        
        // security check
        if (selected_connector_index == -1)
        {
            return false
        }
        return false
    }
    
    // test if point is within a connector
    func testPointInConnector(point:NSPoint) -> Bool{
        
        return false
    }
    
    
    // ------------------ delete methods ------------------
    
    func deleteElementOrConnector(){
        NSLog("deleteElementOrConnector in DrawingView called")
        if (selected_element_index != -1)
        {
            self.deleteElement(selected_element_index)
            // set back selection
            selected_element_index = -1
        }
        if (selected_connector_index != -1)
        {
            self.deleteConnector(selected_connector_index)
            // set back selection
            selected_connector_index = -1
        }
        // redraw
        needsDisplay = true
    }
    
    func deleteElement(element_index:Int){
        NSLog("deleteElement element_index=%d",element_index)
        Elements.removeAtIndex(element_index)
        // search in Connectors for in/out connections with the actual element
    }
    
    func deleteConnector(connector_index:Int){
        NSLog("deleteConnector connector_index=%d",connector_index)
        Connections.removeAtIndex(connector_index)
    }
    
    /*
    -(void)deleteElementOrConnector
    {
    if (selected_element_index != -1)
    {
    [self deleteElement:selected_element_index];
    NSLog(@"deleteElement=%d", selected_element_index);
    // set back selection
    selected_element_index = -1;
    }
    if (selected_connector_index != -1)
    {
    [self deleteConnector: selected_connector_index ];
    NSLog(@"deleteConnector=%d", selected_connector_index);
    // set back selection
    selected_connector_index = -1;
    }
    // update the trackingAreas
    //[self updateTrackingAreas];
    [self setNeedsDisplay:YES];
    
    }
    
    
    -(void)deleteElement:(int)element_index
    {
    // arrayOfElementsCount
    int i;
    int j;
    
    //
    // search for connector that were using arrayOfElements[element_index] and delete them
    
    j=0;
    NSLog(@"arrayOfConnectionElementsCount:%d arrayOfConnectionElementsCount=%d",element_index,arrayOfConnectionElementsCount);
    for (i=0;i<arrayOfConnectionElementsCount;i++)
    {
    if ((arrayOfConnectionElements[i].startPoint_number == element_index) ||
    (arrayOfConnectionElements[i].endPoint_number == element_index))
    {
    //
    NSLog(@"delete connection with startPoint||endPoint lineelement=%d" ,i);
    //[self deleteConnector:i];
    
    }
    else
    {
    arrayOfConnectionElements[j]=arrayOfConnectionElements[i];
    NSLog(@"arrayOfConnectionElements[j=%d]:%d %d %d %d" ,j, arrayOfConnectionElements[j].startPoint_number,
    arrayOfConnectionElements[j].endPoint_number,
    arrayOfConnectionElements[j].startPoint_connectionPoint,
    arrayOfConnectionElements[j].endPoint_connectionPoint );
    j++;
    }
    }
    // clean out old connection elements
    for( i=j;i<arrayOfConnectionElementsCount;i++)
    {
    arrayOfConnectionElements[i].number = -1;
    strcpy(arrayOfConnectionElements[i].description, "not set");
    }
    // set arrayOfConnectionElementsCount to the new value
    arrayOfConnectionElementsCount = j;
    
    // correct startPointnumber or endPoint_number
    for (i=0;i<arrayOfConnectionElementsCount;i++)
    {
    
    if (arrayOfConnectionElements[i].startPoint_number > element_index)
    {
    arrayOfConnectionElements[i].startPoint_number -= 1;
    }
    
    if (arrayOfConnectionElements[i].endPoint_number > element_index)
    {
    arrayOfConnectionElements[i].endPoint_number -= 1;
    }
    }
    
    
    NSLog(@"arrayOfConnectionElementsCount=%d",arrayOfConnectionElementsCount);
    
    // simple overwrite with next element beginning with element_index
    for (i=element_index;i<arrayOfElementsCount-1;i++)
    {
    arrayOfElements[i] = arrayOfElements[i+1];
    arrayOfElements[i].number = i;              // modify number
    }
    arrayOfElementsCount--;
    
    arrayOfElements[arrayOfElementsCount].number = -1;
    strcpy(arrayOfElements[arrayOfElementsCount].description, "not set");
    
    NSLog(@"arrayOfElementsCount=%d",arrayOfElementsCount);
    
    
    }
    
    -(void)deleteConnector:(int)connector_index
    {
    int i;
    int j;
    
    j=0;
    
    for (i=0;i<arrayOfConnectionElementsCount;i++)
    {
    if (i == connector_index)
    {
    NSLog(@"delete connection with connector_index=%d" ,i);
    }
    else
    {
    arrayOfConnectionElements[j]=arrayOfConnectionElements[i];
    arrayOfConnectionElements[j].number = j;
    j++;
    }
    }
    arrayOfConnectionElementsCount = j;
    //
    arrayOfConnectionElements[j].number = -1;
    strcpy(arrayOfConnectionElements[j].description, "not set");
    }
    
 */
    
    /* test if point is within an element
     
     // test if point is within a connector
     - (BOOL)testSelectConnectorInRect:(NSPoint)point
     {
     int i;
     // int j;
     NSRect aRect;
     int startPoint_number;
     int startPoint_connectionPoint;
     int endPoint_number;
     int endPoint_connectionPoint;
     
     NSLog(@"testSelectConnectorInRect");
     
     // test if any connector is selected
     for (i=0; i<arrayOfConnectionElementsCount; i++)
     {
     startPoint_number = arrayOfConnectionElements[i].startPoint_number;
     startPoint_connectionPoint = arrayOfConnectionElements[i].startPoint_connectionPoint;
     endPoint_number = arrayOfConnectionElements[i].endPoint_number;
     endPoint_connectionPoint = arrayOfConnectionElements[i].endPoint_connectionPoint;
     
     aRect.origin.x    = arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].x +
     (arrayOfElements[endPoint_number].connectionPoints[endPoint_connectionPoint].x -
     arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].x)/2;
     
     aRect.origin.y    = arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].y +
     (arrayOfElements[endPoint_number].connectionPoints[endPoint_connectionPoint].y -
     arrayOfElements[startPoint_number].connectionPoints[startPoint_connectionPoint].y)/2;
     
     aRect.origin.x    = aRect.origin.x - CONNRADIUS;
     aRect.origin.y    = aRect.origin.y - CONNRADIUS;
     aRect.size.width  = 2*CONNRADIUS;
     aRect.size.height = 2*CONNRADIUS;
     
     if (NSPointInRect(point, aRect) == YES)
     {
     selected_connector_index = i;
     NSLog(@"selected_connector_index =%d",selected_connector_index);
     //            NSLog(@"Element=%03d:%f,%f,%f,%f %f,%f",i,aRect.origin.x,aRect.origin.y,aRect.size.width,aRect.size.height,point.x,point.y);
     return YES;
     }
     }
     
     selected_connector_index = -1;
     return NO;
     }
     
     
     // test if point is within a connector
     - (BOOL)testPointInConnector:(NSPoint)point
     {
     int i;
     int j;
     NSRect aRect;
     
     // test if a connection point of an element is selected
     for (i=0; i<arrayOfElementsCount; i++)
     {
     for(j=0; j<arrayOfElements[i].number_connectionPoint; j++)
     {
     aRect.origin.x = arrayOfElements[i].connectionPoints[j].x - CONNRADIUS;
     aRect.origin.y = arrayOfElements[i].connectionPoints[j].y - CONNRADIUS;
     aRect.size.width  = 2*CONNRADIUS;
     aRect.size.height = 2*CONNRADIUS;
     if (NSPointInRect(point, aRect) == YES)
     {
     if (startpoint_selected == NO)
     {
     startpoint_index = j;
     startpoint_element = i;
     startpoint_selected = YES;
     NSLog(@"startpoint_selected");
     }
     else
     {
     endpoint_index = j;
     endpoint_element = i;
     startpoint_selected = NO;
     NSLog(@"endpoint_selected");
     }
     return YES;
     }
     }
     }
     // reset start and end of connector
     startpoint_index = -1;
     startpoint_element =  -1;
     endpoint_index = -1;
     endpoint_element =  -1;
     return NO;
     }
     */
    
    
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        //
        NSLog("mouseDown")
        
        var mousePointInView = theEvent.locationInWindow
        mousePointInView = convertPoint(mousePointInView, fromView: nil)
        mousePointInView.x -= frame.origin.x
        mousePointInView.y -= frame.origin.y
        
        NSLog("with selectedTool = %d",selectedTool)
        
        switch selectedTool
        {
        case ARROW_TOOL:
            NSLog("ARROW_TOOL")
            
            if self.testSelectElementInRect(mousePointInView) == true
            {
                NSLog("element selected--> selected_element_index=%d", selected_element_index)
            }
            /*
            if (selected_connector_index != -1)
            {
                if ([self testControlPointSelected:mousePointInView]==YES)
                {
                    NSLog(@"ControlPoint selected");
                    [self setNeedsDisplay:YES];
                    break;
                }
                else
                {
                    NSLog(@"no ControlPoint selected");
                }
            }
            
            if ([self testSelectElementInRect:mousePointInView]==YES)    // mousePointInView instead of snapPointInView!
            {
                NSLog(@"element selected");
            }
            else
            {
                NSLog(@"no element selected");
            }
            
            if ([self testSelectConnectorInRect:mousePointInView]==YES)
            {
                NSLog(@"connector selected");
            }
            else
            {
                NSLog(@"no connector selected");
            }
            
            [self setNeedsDisplay:YES];
            
            
     */
            break
            
        case BUBBLE_TOOL:
            NSLog("BUBBLE_TOOL")
            // add bubble element to array
            self.addABubble(mousePointInView)
            
            break
            
        case TERMINATOR_TOOL:
            NSLog("TERMINATOR_TOOL")
            // add terminator element to array
            self.addASquare(mousePointInView)
            
            break
            
        case STORE_TOOL:
            NSLog("STORE_TOOL")
            // add terminator element to array
            self.addAStore(mousePointInView)
            
            break
            
        case CONNECT_TOOL:
            NSLog("CONNECT_TOOL")
            break
            
        case STATE_TOOL:
            NSLog("STATE_TOOL")
            // add terminator element to array
            self.addAState(mousePointInView)
            
            break
            
        case INPUT_TOOL:
            NSLog("INPUT_TOOL")
            // add terminator element to array
            self.addAInput(mousePointInView)
            
            break
            
        case DELETE_TOOL:
            NSLog("DELETE_TOOL")
            self.deleteElementOrConnector()
            break
            
        default:
            break
        }
        
        
        
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        super.mouseDragged(theEvent)
        
        var mousePointInView = theEvent.locationInWindow
        mousePointInView = convertPoint(mousePointInView, fromView: nil)
        mousePointInView.x -= frame.origin.x
        mousePointInView.y -= frame.origin.y
        //
        
        NSLog("mouseDragged")
        
        switch selectedTool
        {
        case ARROW_TOOL:
            
            /* handle control points of the selected connector
            if (selected_connector_index != -1)
            {
                if (controlpoint1_selected == YES)
                {
                    // set intermediate control point
                    arrayOfConnectionElements[selected_connector_index].controlPoint[0]  = mousePointInView;
                    swift: Connections[selected_connector_index].controlPoint[0]
                }
                else
                    if (controlpoint2_selected == YES)
                    {
                        // set intermediate control point
                        arrayOfConnectionElements[selected_connector_index].controlPoint[1]  = mousePointInView;
                }
            }
            */
        
            // an element is selected so ...
            if (selected_element_index != -1)
            {
                // ... change the position
                let snapedmousePoint:NSPoint = self.snapToGrid(mousePointInView)
                // ... and store it to the selected element
                Elements[selected_element_index].location = snapedmousePoint
            }
            break
            
        default:
            break
        }
        
        needsDisplay = true
        //setNeedsDisplayInRect(bounds)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
        NSLog("mouseUp")
        needsDisplay = true
    }
}
