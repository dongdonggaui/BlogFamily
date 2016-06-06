//
//  UtlsTest.swift
//  BlogFamily
//
//  Created by huangluyang on 16/6/6.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import XCTest
@testable import BlogFamily

class UtlsTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClearHTMLElements() {
        let rawString = "This is a test!"
        let s = "\n\n <h1 class=\"动动拐\">\(rawString)</p>\n "
        let result = s.lkq_stringByClearHTMLElements()
        print("result : \(result)")
        XCTAssert(result == rawString, "html elements should be cleared")
    }
}
