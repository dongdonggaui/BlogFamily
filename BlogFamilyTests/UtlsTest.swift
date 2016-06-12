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
        let result1 = s.lkq_stringByClearHTMLElements()
        print("result1 : \(result1)")
        XCTAssert(result1 == rawString, "html elements should be cleared")
        
        let result2 = rawString.lkq_stringByClearHTMLElements()
        XCTAssert(result2 == rawString, "normal string should not be changed")
        
        let s3 = "<p>\n \n \(rawString)"
        let result3 = s3.lkq_stringByClearHTMLElements()
        print("result3 : \(result3)")
        XCTAssert(result3 == rawString, "white space & new line should be trimmed after clear html elements")
    }
}
