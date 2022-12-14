//
//  DietRecordTestsTwo.swift
//  DietRecordTests
//
//  Created by chun on 2022/12/14.
//

import XCTest

@testable import DietRecord

class DietRecordTestsTwo: XCTestCase {
    var sut: ProfileVC!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ProfileVC()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testButtonTitle() {
        // given
        DRConstant.userID = "9Rl0EpCDacNDQWmmCCJckQUPrnj1"
        let editButton = UIButton()
        sut.editButton = editButton
        
        let user = User(
            userID: "9Rl0EpCDacNDQWmmCCJckQUPrnj1",
            userSelfID: "",
            following: [],
            followers: [],
            blocks: [],
            request: [],
            userImageURL: DRConstant.placeholderURL,
            username: "",
            goal: [],
            waterGoal: "",
            weightGoal: "")

        // when
        sut.configureUI(userData: user)

        // then
        XCTAssertEqual(
            sut.editButton.title(for: .normal),
            "查看個人資料",
            "The title of edit button in the profile page is wrong.")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}
