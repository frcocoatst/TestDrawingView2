//
//  DrawingView.swift
//  TestDrawingView
//
//  Created by Friedrich HAEUPL on 11.05.16.
//  Copyright © 2016 Friedrich HAEUPL. All rights reserved.
//

import Cocoa
import Foundation

let unitSize:NSSize  = NSMakeSize(1.0, 1.0)

let LAYOUTSIZE_X:CGFloat = 3000.0
let LAYOUTSIZE_Y:CGFloat = 2000.0

let WIDTH:CGFloat = 80
let HEIGHT:CGFloat = 30
let RADIUS:CGFloat = 50
let CONNRADIUS:CGFloat = 5
let SELECTRADIUS:CGFloat = 20
let STOREHEIGHT:CGFloat = 40
let STOREWIDTH :CGFloat = 60

let TRACK_RADIUS:Int = 100
let GRID_RADIUS:Int = 150

let TEXTOFFSET:CGFloat = 45

var selectedTool:Int = 0
var selected_element_index = -1
var selected_connector_index = -1

var startpoint_selected:Bool = false
var startpoint_element = -1
var startpoint_index = -1
var endpoint_element = -1
var endpoint_index = -1

var showConnectionPoints:Bool = false


let TYPE_BUBBLE     = 1
let TYPE_TERMINATOR = 2
let TYPE_STORE      = 3
let CONNECT         = 4
let TYPE_STATE      = 5
let TYPE_INPUT      = 6

let DATAFLOW        = 0
let CONTROLFLOW     = 1
let COMBINEDFLOW    = 2

/// DrawingView - subclass of NSView
///
///
class DrawingView: NSView{
    
    // pages demo http://stackoverflow.com/questions/24378013/struct-array-initialization-in-swift
    var Pages = [Page]()
    var PageCounter = 0
    
    // create an array of Element
    //var Elements = [Element]()
    //var ElementCounter = 0
    
    //var Connections = [Connection]()
    //var ConnectionCounter = 0
    
    var controlpoint1_selected:Bool = false
    var controlpoint2_selected:Bool = false
    
    //var referenceToDraw:NSAttributedString
    var zoomfactor:CGFloat = 1.0
    
    // initialize
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        /*
        Pages.append(Page(number: 0,
            type: 0, name: " ", description: " ",
            number_elements: 0, Elements: Elements,
            number_connections: 0, Connections: Connections))
        */
        Pages.append(self.createEmptyPage())
        NSLog("%d",Pages.count)
        
    }
    
    func createEmptyPage() -> Page{
    
        let page:Page = Page( number: -1,
                              type: -1,
                              name: "",
                              description: "",
                              //
                              number_elements: 0,           // actual number of elements
                              Elements:[Element](),         // empty [] array of elements
                              number_connections: 0,        // actual number of connections
                              Connections:[Connection]()    // empty[] array of connections
                            )
        return page
    }
    
    // blow up contentsize
    override var intrinsicContentSize: NSSize {
        
        NSLog("Zoom = %f intrinsicContentSize = %f %f",zoomfactor, 3000.0*zoomfactor, 2000.0*zoomfactor)
        // tbd.: Fehler bei 0.5
        return NSMakeSize(zoomfactor*LAYOUTSIZE_X, zoomfactor*LAYOUTSIZE_Y)
    }
    
    // drawRect
    override func drawRect(dirtyRect: NSRect)
    {
        NSColor.whiteColor().setFill()
        NSRectFill(self.bounds)
        //
        super.drawRect(dirtyRect)
        //
        self.drawGrid()
        self.drawAllElements()
        self.drawAllConnectors()
    }
    /*
     /// testPointInRect - tests if point is in rectangle
     /// - parameter point: point where to add
     ///
     func testPointInRect(point: NSPoint)->Bool {
     return false
     
     }
     */
    
    /// setBubbleOrConnectorName - sets the name
    /// - parameter text: name
    ///
    func setBubbleOrConnectorName(text: NSString){
        NSLog("setBubbleOrConnectorName = %@",text)
        
    }
    
    func resetScaling()
    {
        //[self scaleUnitSquareToSize:[self convertSize:unitSize fromView:nil]];
        self.scaleUnitSquareToSize(self.convertSize(unitSize, fromView:nil))
    }
    /// setViewSize - sets the size of the view
    /// - parameter value: size
    ///
    func setViewSize(value:Double)
    {
        NSLog("setViewSize = %f",value)
        //[self resetScaling]; is:
        //      static const NSSize unitSize = {1.0, 1.0};
        //      NSSize unitSize = {1.0, 1.0}
        //      [self scaleUnitSquareToSize:[self convertSize:unitSize fromView:nil]];
        
        // ????? self.scaleUnitSquareToSize (self.convertSize(NSMakeSize(CGFloat(1.0), CGFloat(1.0)), fromView:nil)
        self.resetScaling()
        
        // First, match our scaling to the window's coordinate system
        //[self scaleUnitSquareToSize:NSMakeSize(value, value)];
        self.scaleUnitSquareToSize (NSMakeSize(CGFloat(value), CGFloat(value)))
        zoomfactor = CGFloat(value)
        
        // Then, set the scale.
        
        // Important, changing the scale doesn't invalidate the display
        //[self setNeedsDisplay:YES];
        needsDisplay = true
    }
    
    /// setSelectedTool - sets the size of the view
    /// - parameter tool: selected tool
    ///
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
        if selectedTool == ARROW_TOOL || selectedTool == CONNECT_TOOL
        {
            showConnectionPoints=true
        }
        else
        {
            showConnectionPoints=false
        }
        needsDisplay = true
    }
    
    
    /// snapToGrid - sets the clickPoint to a gridPoint
    /// - parameter clickPoint: clickpoint
    /// - returns: nearest gridpoint
    func snapToGrid(clickPoint:NSPoint) -> NSPoint{
        //var snapPoint:NSPoint
        var x:Int
        var y:Int
        
        x = (Int(clickPoint.x) + GRID_RADIUS/2)/GRID_RADIUS
        y = (Int(clickPoint.y) + GRID_RADIUS/2)/GRID_RADIUS
        
        // omit border points 
        // TBD calculate from LAYOUTSIZE_X _Y and GRID_RADIUS
        if x==0
        {
            x=1
        }
        if x==20
        {
            x=19
        }
        if y==0
        {
            y=1
        }
        if y==13
        {
            y=12
        }
        
        return NSPoint(x:CGFloat(x * GRID_RADIUS), y:CGFloat(y * GRID_RADIUS))
        //
    }
    
    
    
    /** addABubble - adds a bubble at a certain location
    /// - parameter atPoint: point where to add
    ///
     */
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
        Pages[0].Elements.append(Element(number: Pages[0].number_elements,
            type: TYPE_BUBBLE,
            name: "short name",
            description: "long bubble description",
            location: snapedmousePoint,
            number_connectionPoint: 12,
            connectionPoints: cPoints))
        // increase counter
        //ElementCounter += 1
        
        Pages[0].number_elements += 1   // Update number_elements
        
        NSLog("Pages[0].Elements --> \(Pages[0].Elements[0].name) \(Pages[0].Elements[0].number)")
        /*
         */
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
        Pages[0].Elements.append(Element(number: Pages[0].number_elements,
            type: TYPE_TERMINATOR,
            name: "short name",
            description: "long terminator description",
            location: snapedmousePoint,
            number_connectionPoint: 12,
            connectionPoints: cPoints))
        
        Pages[0].number_elements += 1   // Update number_elements
        
        NSLog("Pages[0].Elements --> \(Pages[0].Elements[0].name) \(Pages[0].Elements[0].number)")

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
        
        
        Pages[0].Elements.append(Element(number: Pages[0].number_elements,
            type: TYPE_STORE,
            name: "short name",
            description: "long store description",
            location: snapedmousePoint,
            number_connectionPoint: 10,
            connectionPoints: cPoints))
        
        
        Pages[0].number_elements += 1   // Update number_elements
        
        NSLog("Pages[0].Elements --> \(Pages[0].Elements[0].name) \(Pages[0].Elements[0].number)")
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
        
        Pages[0].Elements.append(Element(number: Pages[0].number_elements,
            type: TYPE_INPUT,
            name: "short name",
            description: "long input description",
            location: snapedmousePoint,
            number_connectionPoint: 6,
            connectionPoints: cPoints))
        
        Pages[0].number_elements += 1   // Update number_elements
        
        NSLog("Pages[0].Elements --> \(Pages[0].Elements[0].name) \(Pages[0].Elements[0].number)")
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
    
        
        
        Pages[0].Elements.append(Element(number: Pages[0].number_elements,
            type: TYPE_STATE,
            name: "short name",
            description: "long bubble description",
            location: snapedmousePoint,
            number_connectionPoint: 12,
            connectionPoints: cPoints))
        
        Pages[0].number_elements += 1   // Update number_elements
        
        NSLog("Pages[0].Elements --> \(Pages[0].Elements[0].name) \(Pages[0].Elements[0].number)")
    }
    
    
    
    func addAConnector()
    {
        NSLog("addAConnector: ConnectionCounter=%d", Pages[0].number_connections)
        
        // add control points
        var controlPoint_1 = NSPoint()
        var controlPoint_2 = NSPoint()
        var labelPoint = NSPoint()
        
        let start:NSPoint = NSPoint(x:Pages[0].Elements[startpoint_element].location.x +
                                      Pages[0].Elements[startpoint_element].connectionPoints[startpoint_index].x,
                                    y:Pages[0].Elements[startpoint_element].location.y +
                                      Pages[0].Elements[startpoint_element].connectionPoints[startpoint_index].y)
        
        let end:NSPoint   = NSPoint(x:Pages[0].Elements[endpoint_element].location.x +
                                      Pages[0].Elements[endpoint_element].connectionPoints[endpoint_index].x,
                                    y:Pages[0].Elements[endpoint_element].location.y +
                                      Pages[0].Elements[endpoint_element].connectionPoints[endpoint_index].y)
        
        let length:Float = hypotf(Float(end.x - start.x), Float(end.y - start.y))
        
        if length > 10.0
        {
            controlPoint_1 = NSPoint(x: start.x + (end.x-start.x)/4, y: start.y + (end.y-start.y)/4)
            controlPoint_2 = NSPoint(x: start.x + (end.x-start.x)*3/4, y: start.y + (end.y-start.y)*3/4)
            // TBD: calculate the label point
            labelPoint = NSPoint(x: start.x + (end.x-start.x)/4, y: start.y + (end.y-start.y)/4)
        }
        else
        {
            controlPoint_1 = start
            controlPoint_2 = end
            // TBD: calculate the label point
            labelPoint = start
        }
        
        Pages[0].Connections.append(Connection(number:Pages[0].number_connections,
            type:DATAFLOW,
            name: "flow name",
            description: "long flow description",
            startPoint_number:  startpoint_element,
            startPoint_connectionPoint: startpoint_index,
            endPoint_number: endpoint_element,
            endPoint_connectionPoint: endpoint_index,
            controlPoint1:controlPoint_1,
            controlPoint2:controlPoint_2,
            labelPoint: labelPoint
            ))
        
        Pages[0].number_connections += 1     // Update number_connections
        
        // Demo Printout
        for i in 0..<Pages[0].number_connections            // out of range ???? 
        {
            NSLog("Pages[0].Connections[%d] -> \(Pages[0].Connections[i].name) \(Pages[0].Connections[i].number)",i)
        }
        
        // -------------------
        // Modification tryout
        Pages[0].Connections[0].number = 11
        Pages[0].Connections[0].name = "flow name modified"
        Pages[0].Connections[0].description = "modified"
        // NSLog("Pages[0].Connections[0] --> \(Pages[0].Connections[0].name) \(Pages[0].Connections[0].number)")


    }
    
    func drawGrid()
    {//  grid points
        let path:NSBezierPath = NSBezierPath()
        
        for i in 1..<20 {
            for j in 1..<13 {
                
                // TRACK_RADIUS
                let x_pos = CGFloat(i * GRID_RADIUS)
                let y_pos = CGFloat(j * GRID_RADIUS)
                
                path.removeAllPoints()
                path.moveToPoint(NSMakePoint(x_pos - 5,y_pos))
                path.lineToPoint(NSMakePoint(x_pos + 5,y_pos))
                path.moveToPoint(NSMakePoint(x_pos ,y_pos - 5))
                path.lineToPoint(NSMakePoint(x_pos ,y_pos + 5))
                path.lineWidth = 0.1
                
                path.stroke()
                
            }
        }
    }
    
    func drawAllConnectors()
    {
        //var referencePoint:NSPoint
        //var textPoint:NSPoint
        
        var dotRect: NSRect = NSRect()
        let apath  = NSBezierPath()
        let mycurve = NSBezierPath()
        
        //NSLog("drawAllConnectors")
        
        for (index,c) in Pages[0].Connections.enumerate(){
            
            if ((selected_connector_index != -1) && (selected_connector_index == index))
            {
                NSColor.redColor().set()
            }
            else
            {
                NSColor.greenColor().set()
            }
            let element_start:Int   = c.startPoint_number
            let conn_start:Int      = c.startPoint_connectionPoint
            let element_end:Int     = c.endPoint_number
            let conn_end:Int        = c.endPoint_connectionPoint
            
            let start:NSPoint = NSPoint(x:(Pages[0].Elements[element_start].location.x +
                                           Pages[0].Elements[element_start].connectionPoints[conn_start].x),
                                        y:(Pages[0].Elements[element_start].location.y +
                                           Pages[0].Elements[element_start].connectionPoints[conn_start].y))
            
            let end:NSPoint   = NSPoint(x:(Pages[0].Elements[element_end].location.x +
                                           Pages[0].Elements[element_end].connectionPoints[conn_end].x),
                                        y:(Pages[0].Elements[element_end].location.y +
                                           Pages[0].Elements[element_end].connectionPoints[conn_end].y))
            
            let length:Float = hypotf(Float(end.x - start.x),Float(end.y - start.y))
            
            if (length > 1.0)
            {
                // get the controlpoints
                let controlPoint_1 = c.controlPoint1
                let controlPoint_2 = c.controlPoint2
                
                // show the selection point of a connector
                if showConnectionPoints == true
                {
                    var aRect:NSRect=NSRect() //
                    
                    aRect.origin.x    = Pages[0].Elements[element_start].location.x +
                                        Pages[0].Elements[element_start].connectionPoints[conn_start].x +
                                       (Pages[0].Elements[element_end].location.x +
                                        Pages[0].Elements[element_end].connectionPoints[conn_end].x -
                                        Pages[0].Elements[element_start].location.x -
                                        Pages[0].Elements[element_start].connectionPoints[conn_start].x)/2
                    
                    aRect.origin.y    = Pages[0].Elements[element_start].location.y +
                                        Pages[0].Elements[element_start].connectionPoints[conn_start].y +
                                       (Pages[0].Elements[element_end].location.y +
                                        Pages[0].Elements[element_end].connectionPoints[conn_end].y -
                                        Pages[0].Elements[element_start].location.y -
                                        Pages[0].Elements[element_start].connectionPoints[conn_start].y)/2
                    
                    aRect.origin.x    = aRect.origin.x - CONNRADIUS
                    aRect.origin.y    = aRect.origin.y - CONNRADIUS
                    aRect.size.width  = 2*CONNRADIUS
                    aRect.size.height = 2*CONNRADIUS
                    
                    apath.removeAllPoints()
                    apath.appendBezierPathWithOvalInRect(aRect)
                    apath.lineWidth = 1
                    apath.stroke()
                }
                
                // -------------------- show the control points
                if (selected_connector_index != -1)
                {
                    dotRect.origin.x = controlPoint_1.x - CONNRADIUS
                    dotRect.origin.y = controlPoint_1.y - CONNRADIUS
                    dotRect.size.width  = 2 * CONNRADIUS
                    dotRect.size.height = 2 * CONNRADIUS
                    
                    apath.removeAllPoints()
                    apath.appendBezierPathWithOvalInRect(dotRect)
                    apath.lineWidth = 1
                    apath.stroke()
                    
                    dotRect.origin.x = controlPoint_2.x - CONNRADIUS
                    dotRect.origin.y = controlPoint_2.y - CONNRADIUS
                    dotRect.size.width  = 2 * CONNRADIUS
                    dotRect.size.height = 2 * CONNRADIUS
                    
                    apath.appendBezierPathWithOvalInRect(dotRect)
                    apath.lineWidth = 1
                    apath.stroke()
                }
                if (selected_connector_index == index)
                {
                    apath.removeAllPoints()
                    apath.moveToPoint(start)
                    apath.lineToPoint(controlPoint_1)
                    apath.stroke()
                    
                    apath.moveToPoint(end)
                    apath.lineToPoint(controlPoint_2)
                    apath.stroke()
                }
                
                // show resulting curve
                mycurve.appendBezierPath(NSBezierPath.curveFromPointtoPointWithcontrolPoints(start, endPoint: end,
                    controlPoint1: controlPoint_1, controlPoint2: controlPoint_2,
                    tailWidth: 1, headWidth: 15, headLength: 15))
                
                // length category
                // NSLog("---> length of bezierpath = %f", mycurve.lenght)
                
                mycurve.stroke()
                
                // Draw the connector text
                let hypothenuse:CGFloat = CGFloat(length)  // TBD remove
                
                let textPoint:NSPoint = NSMakePoint(end.x - (end.x - start.x)*TEXTOFFSET/hypothenuse,
                                                    end.y - (end.y - start.y)*TEXTOFFSET/hypothenuse)
                
                
                let text: NSString = c.name + String("\n") + String(format:"%d", c.number) + String(format:"(%d)", index) + String("\n") + c.description
                
                let font = NSFont(name: "Menlo", size: 10.0)
                
                let textStyle = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
                textStyle.alignment = NSTextAlignment.Center
                textStyle.lineHeightMultiple = 1.2
                textStyle.lineBreakMode = .ByWordWrapping
                
                let textColor = NSColor.blueColor()
                
                let textFontAttributes = [
                    NSFontAttributeName : font!,
                    NSForegroundColorAttributeName: textColor,
                    NSParagraphStyleAttributeName: textStyle
                ]
                // TBD figure out how big the string is going to be so we can center it
                // http://stackoverflow.com/questions/24666515/how-do-i-make-an-attributed-string-using-swift
                
                let textSize = text.sizeWithAttributes(textFontAttributes)
                // NSLog("textSize.w=%f .h=%f", textSize.width, textSize.height)
                
                var referencePoint:NSPoint = NSMakePoint(0,0)
                
                // figure out where to draw the reference - avoiding overlay of line & text
                if ((end.x - start.x)>=0)
                {
                    // left of end point
                    // subtract referenceSize.width
                    referencePoint.x = textPoint.x - textSize.width;
                    if((end.y - start.y)>=0)
                    {
                        // above
                        referencePoint.y  = textPoint.y;
                    }
                    else
                    {
                        // subtract referenceSize.height
                        referencePoint.y  = textPoint.y - textSize.height;
                    }
                }
                else
                {
                    // right of end point
                    referencePoint.x  = textPoint.x;
                    if((end.y - start.y)>=0)
                    {
                        // above
                        referencePoint.y  = textPoint.y;
                    }
                    else
                    {
                        // subtract referenceSize.height
                        referencePoint.y  = textPoint.y - textSize.height;
                    }

                }
                // finally draw the text
                text.drawAtPoint(referencePoint, withAttributes: textFontAttributes)
                //
                // TBD var labelPoint:  NSPoint  // point where the label is placed TBD ???
                //
            }
            else
            {
                NSLog("distance very small")
            }
        }
        
    }
    
    /// drawAllElements - draws alle elements
    ///
    func drawAllElements()
    {
        let path = NSBezierPath()
        let apath = NSBezierPath()
        
        // selected_element_index = 2  // change this done in testSelectElementInRect
        //NSLog("drawAllElements")
        
        for (index,e) in Pages[0].Elements.enumerate(){
            
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
                // http://stackoverflow.com/questions/26201844/swift-drawing-text-with-drawinrectwithattributes
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
    
    // ----------------- TBD draw text into bubble etc.
    
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
    
    /// testSelectElementInRect - tests if an element was selected by a click
    /// - parameter point: point where clicked
    /// - returns: True or False
    ///
    /// TBD: don't allow selected_element_index and selected_connector_index to be set at the same time
    ///
    func testSelectElementInRect(point:NSPoint) -> Bool{
        
        for (index,e) in Pages[0].Elements.enumerate(){
            let aRect = NSRect(x: e.location.x - RADIUS,
                               y: e.location.y - RADIUS,
                               width: 2*RADIUS,
                               height: 2*RADIUS)
            
            if NSPointInRect(point, aRect){
                // security check  -- reset selected connector
                selected_connector_index = -1

                selected_element_index = index
                NSLog("selected_element_index =%d",selected_element_index)
                return true
            }
            
        }
        // security reset selected element
        selected_element_index == -1
        return false
    }
    
    /// testControlPointSelected - tests if a control point was selected by a click
    /// - parameter point: point where clicked
    /// - returns: True or False
    func testControlPointSelected(point:NSPoint) -> Bool{
        
        // security check
        if (selected_connector_index == -1)
        {
            return false
        }
        
        // TBD possibly relative corrordinates add Connections[selected_connector_index].location.x .y ???
        
        // get the controlpoints
        let controlPoint_1 : NSPoint = Pages[0].Connections[selected_connector_index].controlPoint1
        let controlPoint_2 : NSPoint = Pages[0].Connections[selected_connector_index].controlPoint2
        
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
    
    /// testSelectConnectorInRect - tests if a connector was selected by a click
    /// - parameter point: point where clicked
    /// - returns: True or False
    func testSelectConnectorInRect(point:NSPoint) -> Bool{
        
        var startPoint_number:Int
        var startPoint_connectionPoint:Int
        var endPoint_number:Int
        var endPoint_connectionPoint:Int
        
        NSLog("testSelectConnectorInRect")
        
        // test if any connector is selected
        // enumerate over all connectors
        for (index,c) in Pages[0].Connections.enumerate(){
            
            startPoint_number = c.startPoint_number
            startPoint_connectionPoint = c.startPoint_connectionPoint
            endPoint_number = c.endPoint_number
            endPoint_connectionPoint = c.endPoint_connectionPoint
            
            var aRect:NSRect=NSRect() // TBD: possibly add e.location.x and e.location.y
            
            //
            aRect.origin.x    = Pages[0].Elements[startPoint_number].location.x +
                                Pages[0].Elements[startPoint_number].connectionPoints[startPoint_connectionPoint].x +
                               (Pages[0].Elements[endPoint_number].location.x +
                                Pages[0].Elements[endPoint_number].connectionPoints[endPoint_connectionPoint].x -
                                Pages[0].Elements[startPoint_number].location.x -
                                Pages[0].Elements[startPoint_number].connectionPoints[startPoint_connectionPoint].x)/2
            
            aRect.origin.y    = Pages[0].Elements[startPoint_number].location.y +
                                Pages[0].Elements[startPoint_number].connectionPoints[startPoint_connectionPoint].y +
                               (Pages[0].Elements[endPoint_number].location.y +
                                Pages[0].Elements[endPoint_number].connectionPoints[endPoint_connectionPoint].y -
                                Pages[0].Elements[startPoint_number].location.y -
                                Pages[0].Elements[startPoint_number].connectionPoints[startPoint_connectionPoint].y)/2
            
            aRect.origin.x    = aRect.origin.x - CONNRADIUS
            aRect.origin.y    = aRect.origin.y - CONNRADIUS
            aRect.size.width  = 2*CONNRADIUS
            aRect.size.height = 2*CONNRADIUS
            
            if NSPointInRect(point, aRect){
                
                // security reset selected element
                selected_element_index = -1
                
                selected_connector_index = index
                NSLog("selected_connector_index =%d",selected_connector_index)
                return true
            }
        }
        // security reset selected connector
        selected_connector_index == -1
        return false
    }

    
    /// testPointInConnector - tests if a point is within a connectorpoint
    /// - parameter point: point where clicked
    /// - returns: True or False
    func testPointInConnector(point:NSPoint) -> Bool{
        
        // enumerate over all elements
        for (index,e) in Pages[0].Elements.enumerate(){
            
            // iterate over all connectionPoints
            for (cindex,cp) in e.connectionPoints.enumerate(){
                
                // rect around a connectionPoint            // TBD: possibly add e.location.x and e.location.y
                let aRect = NSRect(x: e.location.x + cp.x - CONNRADIUS,
                                   y: e.location.y + cp.y - CONNRADIUS,
                                   width: 2*CONNRADIUS,
                                   height: 2*CONNRADIUS)
                
                //
                if NSPointInRect(point, aRect){
                    if (startpoint_selected == false)
                    {
                        startpoint_index = cindex
                        startpoint_element = index
                        startpoint_selected = true
                        NSLog("startpoint_selected")
                    }
                    else
                    {
                        endpoint_index = cindex
                        endpoint_element = index
                        startpoint_selected = false
                        NSLog("endpoint_selected")
                    }
                    return true
                }
            }
        }
        // reset start and end of connector
        startpoint_index = -1
        startpoint_element =  -1
        endpoint_index = -1
        endpoint_element =  -1
        return false
    }
    
    
    // ------------------ delete methods ------------------
    /// deleteElementOrConnector - deletes an element or a connector
    ///
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
    
    /// deleteElement - delete an element
    /// - parameter element_index: index of the element to be deleted
    /// 
    ///
    func deleteElement(element_index:Int){
        NSLog("deleteElement element_index=%d",element_index)
        Pages[0].Elements.removeAtIndex(element_index)
        
        // search in Connectors for in/out connections with the actual element
        // see http://stackoverflow.com/questions/28323848/removing-from-array-during-enumeration-in-swift
        for (index,c) in Pages[0].Connections.enumerate().reverse(){
            if c.startPoint_number == element_index || c.endPoint_number == element_index{
                Pages[0].Connections.removeAtIndex(index)
                Pages[0].number_connections -= 1  // ???
            }
        }
        
        // correct references to the elements where the connections are made
        for (index,c) in Pages[0].Connections.enumerate()
        {
            if c.startPoint_number > element_index
            {
                Pages[0].Connections[index].startPoint_number = c.startPoint_number - 1
            }
            
            if c.endPoint_number > element_index
            {
                Pages[0].Connections[index].endPoint_number = c.endPoint_number - 1
            }
        }
        
    }
    
    /// deleteConnector - delete a connector
    /// - parameter connector_index: index of the connector to be deleted
    ///
    /// TBD: if the connector is selected and the Bubble that is source or target of the connector
    ///      it crashes, as the connector is already removed (by the bubble remove) when trying to delete the connector ...
    ///
    func deleteConnector(connector_index:Int){
        NSLog("deleteConnector connector_index=%d",connector_index)
        Pages[0].Connections.removeAtIndex(connector_index)
        //
        Pages[0].number_connections -= 1  // ???
    }
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        //
        NSLog("mouseDown")
        
        // check additional modifiers
        let modifierFlags = theEvent.modifierFlags;
        //if (modifierFlags.contains(.ControlKeyMask))
        //if (modifierFlags.contains(.AlternateKeyMask))
        if (modifierFlags.contains(.CommandKeyMask))
        {
            if let menu = self.menuForEvent(theEvent)
            {
                NSMenu.popUpContextMenu(menu, withEvent:theEvent, forView:self);
            }
        }

        
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
            
            if selected_connector_index != -1
            {
                if self.testControlPointSelected(mousePointInView)==true
                {
                    NSLog("ControlPoint selected")
                    //[self setNeedsDisplay:YES]
                    needsDisplay = true
                    break
                }
                else
                {
                    NSLog("no ControlPoint selected")
                }
            }
            
            if self.testSelectElementInRect(mousePointInView) == true    // mousePointInView instead of snapPointInView!
            {
                NSLog("element selected")
            }
            else
            {
                NSLog("no element selected")
            }
            
            if self.testSelectConnectorInRect(mousePointInView) == true
            {
                NSLog("connector selected")
            }
            else
            {
                NSLog("no connector selected")
            }
            
            needsDisplay = true
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
            if self.testPointInConnector(mousePointInView) == true
            {
                NSLog("connector")
            }
            else
            {
                NSLog("no connector")
            }
            
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
    
    // see http://younata.github.io/2015/08/14/osx-programming-programmatic-menu-buttons/
    
    override func menuForEvent(event: NSEvent) -> NSMenu? {
        
        let menu = NSMenu(title: "Context Menu")
        
        let menuItem = NSMenuItem(title: "Information", action: #selector(DrawingView.didSelectMenuItem(_:)), keyEquivalent: "")
        menuItem.target = self
        menu.addItem(menuItem)
        
        menu.addItem(NSMenuItem(title: "Context1", action: #selector(DrawingView.context1(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Context2", action: #selector(DrawingView.context2(_:)), keyEquivalent: "e"))
        
        return menu
    }
    
    func didSelectMenuItem(menuItem: NSMenuItem) {
        NSLog("Selected menu item \(menuItem)")
    }
    func context1(menuItem: NSMenuItem) {
        NSLog("Context1 selected menu item \(menuItem)")
    }
    func context2(menuItem: NSMenuItem) {
        NSLog("Context2 selected menu item \(menuItem)")
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
                Pages[0].Elements[selected_element_index].location = snapedmousePoint
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
        // ---
        var mousePointInView = theEvent.locationInWindow
        mousePointInView = convertPoint(mousePointInView, fromView: nil)
        mousePointInView.x -= frame.origin.x
        mousePointInView.y -= frame.origin.y
        
        // slet snapPointInView:NSPoint    = self.snapToGrid(mousePointInView)
        
        switch(selectedTool)
        {
        case ARROW_TOOL:
            if selected_connector_index != -1
            {
                if controlpoint1_selected == true
                {
                    
                    //arrayOfConnectionElements[selected_connector_index].controlPoint[0]  = mousePointInView;
                    Pages[0].Connections[selected_connector_index].controlPoint1  = mousePointInView
                    
                    // set back
                    controlpoint1_selected = false
                }
                else
                if controlpoint2_selected == true
                {
                    //arrayOfConnectionElements[selected_connector_index].controlPoint[1]  = mousePointInView;
                    Pages[0].Connections[selected_connector_index].controlPoint2  = mousePointInView
                    
                    // set back
                    controlpoint2_selected = false
                }
            }

            break
            
        case CONNECT_TOOL:
            if startpoint_selected == true
            {
                NSLog("startpoint_index=%d startpoint_element=%d",startpoint_index, startpoint_element)
            }
            else
            if endpoint_index > -1 && startpoint_index > -1    // both exist
            {
                if endpoint_element != startpoint_element
                {
                    NSLog("endpoint_index=%d  endpoint_element=%d",endpoint_index, endpoint_element)
                        
                    self.addAConnector()
                    needsDisplay = true
                }
            }
            break
            
        default:
            break
        }

        needsDisplay = true
    }

}