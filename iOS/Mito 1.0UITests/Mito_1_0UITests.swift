//
//  Mito_1_0UITests.swift
//  Mito 1.0UITests
//
//  Created by Benny on 2/22/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import XCTest

class Mito_1_0UITests: XCTestCase {
        
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
    
    func testBasicCurrencyInCartCheckoutRounding() {
        
        let app = XCUIApplication()
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("tombrady@uw.edu")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123456")
        
        let loginButton = app.buttons["LOGIN"]
        loginButton.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        app.tabBars.buttons["Search"].tap()
        
//        let searchButton = app.searchFields["Search"]
//        searchButton.tap()
        
        let searchSearchField = app.searchFields["Search"]
        searchSearchField.tap()
        searchSearchField.typeText("duck")
        app.typeText("\r")
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Aurora World Mini Flopsie Toy Duckling Plush, 8\""]/*[[".cells.staticTexts[\"Aurora World Mini Flopsie Toy Duckling Plush, 8\\\"\"]",".staticTexts[\"Aurora World Mini Flopsie Toy Duckling Plush, 8\\\"\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let addToCartButton = app.buttons["Add to Cart"]
        addToCartButton.tap()
        
        let okButton = app.alerts["Done"].buttons["OK"]
        okButton.tap()
        
        let backButton = app.buttons["Back"]
        backButton.tap()
//        searchButton.tap()
        searchSearchField.tap()
        searchSearchField.typeText("hard")
        app.typeText("en\r")
        tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier:"$140.00")/*[[".cells.containing(.staticText, identifier:\"Harden Vol. 1 Mens in Black\/Scarlet by Adidas, 11\")",".cells.containing(.staticText, identifier:\"$140.00\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.staticTexts["adidas"].tap()
        addToCartButton.tap()
        okButton.tap()
        backButton.tap()
        
        let cartSolidWhiteIconButton = app.buttons["Cart Solid White Icon"]
        cartSolidWhiteIconButton.tap()
        XCTAssert(app.staticTexts["$146.78"].exists)
        
    }
    
    func testAddHardenShoeToCart() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("tombrady@uw.edu")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123456")
        
        let loginButton = app.buttons["LOGIN"]
        loginButton.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        app.tabBars.buttons["Search"].tap()
        
        let searchSearchField = app.searchFields["Search"]
        searchSearchField.tap()
        searchSearchField.typeText("harde")
        app.typeText("n\r")
        XCUIApplication().tables.cells.containing(.staticText, identifier:"adidas Men's Harden Vol 2 Basketball Shoe Red/White Size 11.5 M US").staticTexts["adidas"].tap()
        app.buttons["Add to Cart"].tap()
        app.alerts["Done"].buttons["OK"].tap()
        app.buttons["Back"].tap()
        app.buttons["Cart Solid White Icon"].tap()
        
        XCTAssert(app.staticTexts["Cart has 1 items"].exists)
        
        
    }
    
}
