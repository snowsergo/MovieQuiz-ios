
import XCTest

class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }

    func testExample() throws {
        // UI tests must launch the application that they test
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    func testYesButton() {
        let app = XCUIApplication()
        app.launch()
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её

        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        /// ещё раз находим постер
        sleep(3)
        XCTAssertTrue(indexLabel.label == "2/10")

        XCTAssertFalse(firstPoster == secondPoster) // проверяем, что постеры разные
    }
    func testNoButton() {
        let app = XCUIApplication()
        app.launch()
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        app.buttons["No"].tap() // находим кнопку `Да` и нажимаем её

        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        /// ещё раз находим постер
        sleep(3)
        XCTAssertTrue(indexLabel.label == "2/10")

        XCTAssertFalse(firstPoster == secondPoster) // проверяем, что постеры разные
    }

    func testAlertExist() {
        let app = XCUIApplication()
        app.launch()
        sleep(4)
        var i = 0
        while i < 10 {
            app.buttons["Yes"].tap()
            sleep(2)
            i += 1
        }
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "10/10")
        let resultAlert = app.alerts["result_alert"]
        XCTAssertTrue(resultAlert.exists)
        XCTAssertTrue(resultAlert.label == "Этот раунд окончен")
        XCTAssertTrue(resultAlert.buttons.firstMatch.label == "Сыграть еще раз")
    }
    
    func testAlertDisappear() {
        let app = XCUIApplication()
        app.launch()
        sleep(5)
        var i = 0
        while i < 10 {
            app.buttons["Yes"].tap()
            sleep(5)
            i += 1
        }
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.label == "10/10")
        let resultAlert = app.alerts["result_alert"]
        XCTAssertTrue(resultAlert.exists)
        XCTAssertTrue(resultAlert.label == "Этот раунд окончен")
        XCTAssertTrue(resultAlert.buttons.firstMatch.label == "Сыграть еще раз")
        resultAlert.buttons.firstMatch.tap()
        sleep(4)
        XCTAssertTrue(indexLabel.label == "1/10")
        XCTAssertFalse(resultAlert.exists)
    }
}
