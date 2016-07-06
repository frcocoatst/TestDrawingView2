//
//  TestDrawingViewUITests.swift
//  TestDrawingViewUITests
//
//  Created by Friedrich HAEUPL on 11.05.16.
//  Copyright © 2016 Friedrich HAEUPL. All rights reserved.
//

import XCTest

class TestDrawingViewUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let window = XCUIApplication().windows["Window"]
        let checkBox = window.childrenMatchingType(.CheckBox).elementBoundByIndex(1)
        checkBox.click()
        
        let scrollView = window.childrenMatchingType(.ScrollView).element
        scrollView.click()
        scrollView.click()
        
        let checkBox2 = window.childrenMatchingType(.CheckBox).elementBoundByIndex(4)
        checkBox2.click()
        scrollView.click()
        scrollView.click()
        checkBox.click()
        scrollView.click()
        checkBox2.click()
        scrollView.click()
        scrollView.click()
        scrollView.click()
        scrollView.click()
        
        let checkBox3 = window.childrenMatchingType(.CheckBox).elementBoundByIndex(0)
        checkBox3.click()
        checkBox.click()
        checkBox3.click()
        scrollView.click()
        scrollView.click()
        scrollView.click()
        scrollView.click()
        window.childrenMatchingType(.Button).elementBoundByIndex(0).click()
        checkBox2.click()
        scrollView.click()
        scrollView.click()
        
    }
    
}
