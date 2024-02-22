//
//  SwiftUIChallengeUITests.swift
//  SwiftUIChallengeUITests
//
//  Created by Alexandra Biskulova on 21.02.2024.
//

import XCTest

final class SwiftUIChallengeUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testUI_launchScreen_shouldEnableOpenPaymentButton() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // Then
        let label = app.staticTexts.firstMatch
        XCTAssertNotNil(label.label)
        XCTAssertTrue(label.exists)
        
        XCTAssertEqual(app.descendants(matching: .button).count, 1)
        
        let paymentButton = app.buttons["Open payment"]
        XCTAssertTrue(paymentButton.exists)
        
        let firstScreen = XCTAttachment(screenshot: app.screenshot())
        firstScreen.name = "Launch Screen"
        firstScreen.lifetime = .keepAlways
        add(firstScreen)
    }
    
    func testUI_openPayments_shouldShowLoadingCorrectly() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // When
        let paymentButton = app.buttons["Open payment"]
        paymentButton.tap()
        
        // Then
        let secondScreen = XCTAttachment(screenshot: app.screenshot())
        secondScreen.name = "Payment Loading Screen"
        secondScreen.lifetime = .keepAlways
        add(secondScreen)
        
        XCTAssertTrue(app.activityIndicators.element.exists)
        XCTAssertTrue(app.navigationBars.element.exists)
        let paymentInfoNavigationBar = app.navigationBars["Payment info"]
        XCTAssertEqual(paymentInfoNavigationBar.identifier,"Payment info")
    }

    func testUI_openPayments_shouldShowLoadedPaymentsCorrectly() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // When
        let paymentButton = app.buttons["Open payment"]
        paymentButton.tap()
        
        // Then
        let collectionViewsQuery = app.collectionViews
        XCTAssertTrue(collectionViewsQuery.firstMatch.waitForExistence(timeout: 2))
        
        let paymentScreen = XCTAttachment(screenshot: app.screenshot())
        paymentScreen.name = "Payment Screen"
        paymentScreen.lifetime = .keepAlways
        add(paymentScreen)
    }
    
    func testUI_openPayments_shouldNotShowDoneButtonUntilPaymentSelected() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // When
        let paymentButton = app.buttons["Open payment"]
        paymentButton.tap()
        
        // Then
        let collectionViewsQuery = app.collectionViews
        XCTAssertTrue(collectionViewsQuery.firstMatch.waitForExistence(timeout: 2))
        
        // Done button is hidden until payment method is selected
        let paymentInfoNavigationBarDoneButton = app.navigationBars.buttons["Done"]
        XCTAssertFalse(paymentInfoNavigationBarDoneButton.exists)
        XCTAssertFalse(paymentInfoNavigationBarDoneButton.isHittable)
    }
    
    func testUI_openPayments_shouldShowDoneButtonAfterPaymentSelected() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // When
        let paymentButton = app.buttons["Open payment"]
        paymentButton.tap()
        
        // Then
        let collectionViewsQuery = app.collectionViews
        XCTAssertTrue(collectionViewsQuery.firstMatch.waitForExistence(timeout: 2))
        
        // make selection in the list
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["Google pay"]/*[[".cells.buttons[\"Google pay\"]",".buttons[\"Google pay\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // Done button is visible in navigationbar on payment selection in the list
        let paymentInfoNavigationBarDoneButton = app.navigationBars.buttons["Done"]
        XCTAssertTrue(paymentInfoNavigationBarDoneButton.exists)
        XCTAssertTrue(paymentInfoNavigationBarDoneButton.isHittable)
    }
    
    func testUI_openPayments_shouldSearchCorrectly() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // When
        let paymentButton = app.buttons["Open payment"]
        paymentButton.tap()
        
        // Then
        let collectionViewsQuery = app.collectionViews
        XCTAssertTrue(collectionViewsQuery.firstMatch.waitForExistence(timeout: 2))
        
        let searchSearchField = app.navigationBars.searchFields["Search"]
        XCTAssertTrue(searchSearchField.isHittable)
        searchSearchField.tap()
        searchSearchField.typeText("M")
        // check if only 2 items returned by search (Maestro, Mastercard)
        XCTAssertEqual(collectionViewsQuery.buttons.count, 2)
        
        collectionViewsQuery.buttons["Maestro"].tap()
        XCTAssertTrue(collectionViewsQuery.buttons["Maestro"].isSelected)
        
        // check if all 5 items returned by search
        searchSearchField.buttons["Clear text"].tap()
        XCTAssertEqual(collectionViewsQuery.buttons.count, 5)
        
        // check if search mode off
        app.navigationBars.buttons["Cancel"].tap()
        XCTAssertFalse(searchSearchField.isSelected)
    }
   
    func testUI_openPaymentsAndCloseOnTapDone_shouldEnableFinishButtonOnLaunchScreen() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // When
        let paymentButton = app.buttons["Open payment"]
        paymentButton.tap()
        
        let collectionViewsQuery = app.collectionViews
        XCTAssertTrue(collectionViewsQuery.firstMatch.waitForExistence(timeout: 2))
        
        collectionViewsQuery.buttons.firstMatch.tap()
        
        let paymentInfoNavigationBarDoneButton = app.navigationBars.buttons["Done"]
        XCTAssertTrue(paymentInfoNavigationBarDoneButton.exists)
        paymentInfoNavigationBarDoneButton.tap()
        
        // Then
        let firstScreenWithFinish = XCTAttachment(screenshot: app.screenshot())
        firstScreenWithFinish.name = "Launch Screen with Finish button"
        firstScreenWithFinish.lifetime = .keepAlways
        add(firstScreenWithFinish)
        
        XCTAssertEqual(app.descendants(matching: .button).count, 2)
        
        let finishButton = app.buttons["Finish"]
        XCTAssertTrue(finishButton.exists)
    }
    
    func testUI_selectPaymentAndTapFinishButton_shouldShowFinishScreen() throws {
        // Given
        let app = XCUIApplication()
        app.launch()
        
        // When
        let paymentButton = app.buttons["Open payment"]
        paymentButton.tap()
        
        let collectionViewsQuery = app.collectionViews
        XCTAssertTrue(collectionViewsQuery.firstMatch.waitForExistence(timeout: 2))
        
        collectionViewsQuery.buttons.firstMatch.tap()
        
        let paymentInfoNavigationBarDoneButton = app.navigationBars.buttons["Done"]
        XCTAssertTrue(paymentInfoNavigationBarDoneButton.exists)
        paymentInfoNavigationBarDoneButton.tap()
        
        let finishButton = app.buttons["Finish"]
        XCTAssertTrue(finishButton.exists)
        finishButton.tap()

        //Then
        let finishScreen = XCTAttachment(screenshot: app.screenshot())
        finishScreen.name = "Finish Screen"
        finishScreen.lifetime = .keepAlways
        add(finishScreen)
    }
    
//    func test_S() throws {
//        let app = XCUIApplication()
//        app.launch()
//        
//        XCTAssertEqual(app.descendants(matching: .button).count, 1)
//
//        let paymentButton = app.buttons["Open payment"]
//        XCTAssertTrue(paymentButton.exists)
//        paymentButton.tap()
//        
//        let collectionViewsQuery = app.collectionViews
//        XCTAssertTrue(collectionViewsQuery.firstMatch.waitForExistence(timeout: 2))
//
//        let firstCell = app// collectionViewsQuery.element(boundBy: 0)
//        let start = firstCell.coordinate(withNormalizedOffset: CGVectorMake(0.0, 300.0))
//        let finish = firstCell.coordinate(withNormalizedOffset: CGVectorMake(0.0, 0.0))
//        start.press(forDuration: 0.5, thenDragTo: finish)
//
//        let progressView = app.activityIndicators.element
////        XCTAssertTrue(progressView.exists)
//
//        XCTAssertTrue(progressView.firstMatch.waitForExistence(timeout: 0.5))
//
//        start.press(forDuration: 0.5, thenDragTo: finish)
//
//        XCTAssertTrue(progressView.firstMatch.waitForExistence(timeout: 0.5))
//
//        start.press(forDuration: 1.5, thenDragTo: finish)
//
//        XCTAssertTrue(progressView.firstMatch.waitForExistence(timeout: 0.5))
//
//        start.press(forDuration: 0.5, thenDragTo: finish)
//
//        XCTAssertTrue(progressView.firstMatch.waitForExistence(timeout: 0.5))
//
//        start.press(forDuration: 0.5, thenDragTo: finish)
//
//        XCTAssertTrue(progressView.firstMatch.waitForExistence(timeout: 0.5))
//----
//        let verticalScrollBar1PageCollectionView = app.collectionViews.containing(.other, identifier:"Vertical scroll bar, 1 page").element
//        verticalScrollBar1PageCollectionView.swipeDown()
//        verticalScrollBar1PageCollectionView.swipeDown()
//        verticalScrollBar1PageCollectionView.swipeDown()
//        verticalScrollBar1PageCollectionView.swipeDown(velocity: .slow)
//
//        let progressView = app.activityIndicators.element
//        XCTAssertTrue(progressView.exists)

//        
//        verticalScrollBar1PageCollectionView.swipeDown()
//        verticalScrollBar1PageCollectionView.swipeDown()
//        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Mastercard"]/*[[".cells.buttons[\"Mastercard\"]",".buttons[\"Mastercard\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
//        verticalScrollBar1PageCollectionView.swipeDown()
        
//        XCUIApplication().navigationBars["Payment info"].staticTexts["Payment info"].swipeDown()

//    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
