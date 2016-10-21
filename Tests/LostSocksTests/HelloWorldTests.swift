//
//  HelloWorldTests.swift
//  LostSocks
//
//  Created by Tomas Sykora, jr. on 16/10/2016.
//
//

import XCTest
import Vapor
import HTTP
import Turnstile


class HelloWorldTests: XCTestCase {

    override func setUp() {
        super.setUp()


    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
		let drop = try! fireUpServer()

		let registerRequest = try! Request(method: .post, uri: "/register")
		registerRequest.headers = ["Content-Type" : "application/json"]
		registerRequest.body = JSON(["username" : "username",
		                     "password" : "password"]).makeBody()
		let registerResponse = try! drop.respond(to: registerRequest)

		print(registerResponse)


    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
