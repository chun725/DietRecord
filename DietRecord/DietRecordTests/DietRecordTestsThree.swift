//
//  DietRecordTestsThree.swift
//  DietRecordTests
//
//  Created by chun on 2022/12/14.
//

import XCTest

@testable import DietRecord

class DietRecordTestsThree: XCTestCase {
    var sut: WaterInputVC!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = WaterInputVC()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testChangeWaterCurrent() {
        // given
        let inputTextField = UITextField()
        inputTextField.text = "0"
        sut.inputTextField = inputTextField
        let plusButton = UIButton()
        sut.plusButton = plusButton
        let minusButton = UIButton()
        sut.minusButton = minusButton
        
        sut.plusButton.addTarget(sut, action: #selector(sut.changeWaterCurrent), for: .touchUpInside)
        sut.minusButton.addTarget(sut, action: #selector(sut.changeWaterCurrent), for: .touchUpInside)
        
        // when
        sut.plusButton.sendActions(for: .touchUpInside)
        
        // then
        XCTAssertEqual(
            sut.inputTextField.text,
            "100",
            "The text of the input text field computed from changeWaterCurrent is wrong.")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
