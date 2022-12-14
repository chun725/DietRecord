//
//  DietRecordTests.swift
//  DietRecordTests
//
//  Created by chun on 2022/12/14.
//

import XCTest

@testable import DietRecord

class DietRecordTests: XCTestCase {
    var sut: SetupGoalVC!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = SetupGoalVC()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testTDEE() {
        // given
        let personalInfo = PersonalInfo(
            gender: "女",
            age: "25",
            height: "167",
            weight: "53",
            activityLevel: "輕度活動量",
            dietGoal: "維持體重",
            dietPlan: "一般飲食 (55/15/30)")
        
        // when
        sut.goal = sut.calculateTDEE(personalInfo: personalInfo)
        
        // then
        XCTAssertEqual(sut.goal, ["1852.0", "254.6", "69.4", "61.7"], "Goal computed from calculateTDEE is wrong")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
