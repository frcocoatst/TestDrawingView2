//
//  DrawingView.swift
//  TestDrawingView
//
//  Created by Friedrich HAEUPL on 11.05.16.
//  Copyright © 2016 Friedrich HAEUPL. All rights reserved.
//

import Cocoa


let WIDTH:CGFloat = 80
let HEIGHT:CGFloat = 30
let RADIUS:CGFloat = 50
var selectedTool:Int = 0
let TRACK_RADIUS:Int = 100
let GRID_RADIUS:Int = 120

class DrawingView: NSView{
    
    
    // create an array of Element
    var Elements = [Element]()
    var ElementCounter = 0
    //var referenceToDraw:NSAttributedString
    var zoomfactor:CGFloat = 1.0
    
    // initialize
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    /*  // override func awakeFromNib()
     {
     var f:NSRect = self.frame
     f.size.width = 2000
     f.size.height = 1000
     self.frame = f;
     
     }
     */
    
    // blow up contentsize
    override var intrinsicContentSize: NSSize {
        
        
        NSLog("Zoom = %f intrinsicContentSize = %f %f",zoomfactor, 3000.0*zoomfactor, 2000.0*zoomfactor)
        // tbd.: Fehler bei 0.5
        return NSMakeSize(3000.0*zoomfactor, 2000.0*zoomfactor)
    }
    
    // drawRect
    
    override func drawRect(dirtyRect: NSRect)
    {
        // Examples are taken from:
        
        // let CONNRADIUS = 2.0
        // let SELECTRADIUS = 20
        
        NSColor.whiteColor().setFill()
        NSRectFill(self.bounds)
        //
        super.drawRect(dirtyRect)
        //
        self.drawIt()
    }
    
    func drawIt() {
        // show all elements points
        //
        for e in Elements{
            let path = NSBezierPath()
            
            // ------ draw a Rectangle ------
            //  let rect = NSRect(x: e.location.x, y: e.location.y, width: WIDTH, height: HEIGHT)
            
            //  path.appendBezierPathWithRect(rect)
            //  path.stroke()
            
            // ------ draw the circle ------
            let rect = NSRect(x: e.location.x - RADIUS,
                              y: e.location.y - RADIUS,
                              width: 2*RADIUS,
                              height: 2*RADIUS)
            
            path.appendBezierPathWithOvalInRect(rect)
            path.lineWidth = 2.0
            
            path.stroke()
            
            // let text: NSString = e.name + " \(e.number)"//+ e.description
            // build a long string with linebreaks
            let text: NSString = e.name + String("\n") + String(format:"%d", e.number) + String("\n") + e.description
            
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
            
            //NSLog("number = %d",e.number);
        }
        
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
        NSLog("setSelectedTool in DrawingView with tool: %d",tool);
        selectedTool = tool
        NSLog("selectedTool = %d",selectedTool);
        
        
        switch selectedTool
        {
        case ARROW_TOOL:
            break
        case BUBBLE_TOOL:
            break
        case TERMINATOR_TOOL:
            break
        case STORE_TOOL:
            break
        case CONNECT_TOOL:
            break
        case STATE_TOOL:
            break
        case INPUT_TOOL:
            break
        case DELETE_TOOL:
            break
        default:
            break
            
        }
        
        
        //selectedTool = tool;
        //   ARROW_TOOL,BUBBLE_TOOL,TERMINATOR_TOOL,STORE_TOOL,CONNECT_TOOL,DOT_TOOL,DELETE_TOOL
        
        /* clear all selections
         selected_element_index             = -1;
         selected_connector_index           = -1;
         
         if ((selectedTool==ARROW_TOOL) || (selectedTool==CONNECT_TOOL))
         {
         showConnectionPoints=YES;
         [self setNeedsDisplay:YES];
         }
         else
         {
         showConnectionPoints=NO;
         [self setNeedsDisplay:YES];
         }
         */
    }
    
    func deleteElementOrConnector(){
        NSLog("deleteElementOrConnector in DrawingView called");
    }
    
    func snapToGrid(clickPoint:NSPoint) -> NSPoint{
        //var snapPoint:NSPoint
        var x:Int
        var y:Int
        
        x = (Int(clickPoint.x) + GRID_RADIUS/2)/GRID_RADIUS;
        y = (Int(clickPoint.y) + GRID_RADIUS/2)/GRID_RADIUS;
        
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
    
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        //
        NSLog("mouseDown");
        
        var mousePointInView = theEvent.locationInWindow
        mousePointInView = convertPoint(mousePointInView, fromView: nil)
        mousePointInView.x -= frame.origin.x
        mousePointInView.y -= frame.origin.y
        
        // add element to array
        // Elements.append(Element(number: ElementCounter, type: 1, name: "name", description: "description", location: mousePointInView))
        // snap to Grid
        let snapedmousePoint:NSPoint = self.snapToGrid(mousePointInView)
        NSLog("snapedmousePoint %f %f",snapedmousePoint.x, snapedmousePoint.y)
        
        Elements.append(Element(number: ElementCounter, type: 1, name: "name", description: "description", location: self.snapToGrid(mousePointInView)))
        
        ElementCounter+=1;
        
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        super.mouseDragged(theEvent)
        
        var mousePointInView = theEvent.locationInWindow
        mousePointInView = convertPoint(mousePointInView, fromView: nil)
        mousePointInView.x -= frame.origin.x
        mousePointInView.y -= frame.origin.y
        //
        
        NSLog("mouseDragged");
        
        needsDisplay = true
        //setNeedsDisplayInRect(bounds)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
        NSLog("mouseUp");
        needsDisplay = true
    }
}
