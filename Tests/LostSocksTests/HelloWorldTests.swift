//
//  HelloWorldTests.swift
//  LostSocks
//
//  Created by Tomas Sykora, jr. on 16/10/2016.
//
//

import XCTest


class HelloWorldTests: XCTestCase {

    override func setUp() {
        super.setUp()


    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
		XCTAssert(HelloWorld() != nil)

		

        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
