//
//  ViewController.swift
//  TestDrawingView
//
//  Created by Friedrich HAEUPL on 11.05.16.
//  Copyright © 2016 Friedrich HAEUPL. All rights reserved.
//

import Cocoa


let ARROW_TOOL = 100
let BUBBLE_TOOL = 101
let TERMINATOR_TOOL = 102
let STORE_TOOL = 103
let CONNECT_TOOL = 104
let STATE_TOOL = 105
let INPUT_TOOL = 106
let DELETE_TOOL = 107



class ViewController: NSViewController {
    
    weak var currentOnStateButton : NSButton!
    
    @IBOutlet weak var viewOutlet: DrawingView!
    
    @IBOutlet weak var button1: NSButton!
    @IBOutlet weak var button2: NSButton!
    @IBOutlet weak var button3: NSButton!
    @IBOutlet weak var button4: NSButton!
    @IBOutlet weak var button5: NSButton!
    @IBOutlet weak var button6: NSButton!
    @IBOutlet weak var button7: NSButton!
    @IBOutlet weak var button8: NSButton!
    
    @IBOutlet weak var textOutlet: NSTextField!
    
    @IBOutlet weak var popUpOutlet: NSPopUpButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // select a button in the button matris
        currentOnStateButton = button1
        self.viewOutlet.setSelectedTool(BUBBLE_TOOL) // ARROW_TOOL
        
        // predefine the default string in the textfield
        textOutlet.stringValue = "tbd"
        
        // select the first item of the popup
        popUpOutlet.selectItemAtIndex(0)
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func buttonList() -> Array<NSButton> {
        return [button1, button2, button3, button4,button5, button6, button7]
    }
    
    
    @IBAction func deleteButtonPressed(sender: AnyObject) {
        
        NSLog("deleteButtonPressed pressed");
        // call method in DrawingView
        self.viewOutlet.deleteElementOrConnector()
        
    }
    
    @IBAction func buttonPressed(sender: NSButton) {
        currentOnStateButton.state = NSOffState
        
        for aButton in buttonList()
        {
            if aButton == sender
            {
                aButton.state = NSOnState
                NSLog("button %d pressed",aButton.tag);
                
                // hand over which button was pressed
                self.viewOutlet.setSelectedTool(aButton.tag)
            }
            else
            {
                aButton.state = NSOffState
            }
        }
    }
    
    // ------------ NSTextField -----------
    
    
    @IBAction func textEnteredAction(sender: NSTextField)
    {
        let enteredText = sender.stringValue
        
        NSLog("textEnteredAction = %@",enteredText)
        self.viewOutlet.setBubbleOrConnectorName(enteredText)
    }
    
    // ------------ NSPopUp -------------
    
    @IBAction func scaleAction(sender: AnyObject) {
        
        // possible:
        //let popItem:NSPopUpButton = sender as! NSPopUpButton
        //NSLog("scaleAction title=%@", popItem.title)
        
        NSLog("scaleAction title = %@",String(sender.title))
        NSLog("scaleAction tag   = %d", Int(sender.selectedTag()))
        
        switch Int(sender.selectedTag()) {
        case 0:
            self.viewOutlet.setViewSize(1.0)
            break
        case 1:
            self.viewOutlet.setViewSize(0.5)
            break
        case 2:
            self.viewOutlet.setViewSize(2.0)
            break
        default:
            self.viewOutlet.setViewSize(1.0)
        }
        
    }
    
    
}

