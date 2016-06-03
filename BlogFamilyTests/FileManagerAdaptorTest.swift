//
//  FileManagerAdaptorTest.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/26.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import XCTest
@testable import BlogFamily

class FileManagerAdaptorTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRelativeDirectoryToDocumentWithDirName() {
        let dir = "test"
        let dirPath = FileManagerAdaptor.relativeDirectoryToDocuments(withName: dir)
        XCTAssert((dirPath?.containsString("Documents/test"))!, "dir path should be correctly create")
    }
    
    func testGenerateWebarchiveName() {
        let fileName = FileManagerAdaptor.generateWebarchiveName()
        XCTAssert(fileName.hasSuffix(".webarchive"), "webarchive file name should ended with .webarchive")
    }
    
    func testWebarchiveIdWithFileName() {
        let uuid = "550E8400-E29B-11D4-A716-446655440000"
        let validFileName = "\(uuid).webarchive"
        let invalidFileName = "\(uuid).we"
        
        let validId = FileManagerAdaptor.webarchiveId(withFileName: validFileName)
        XCTAssertNotNil(validId, "archive id from valid file name (like xxxx.webarchive) should not be nil")
        XCTAssert(validId == uuid, "archive id should be identity")
        
        let invalidId = FileManagerAdaptor.webarchiveId(withFileName: invalidFileName)
        XCTAssertNil(invalidId, "archive id from invalid file name should be nil")
    }
    
    func testWebarchivePathWithName() {
        let fileName = FileManagerAdaptor.generateWebarchiveName()
        let webarchiveDir = FileManagerAdaptor.webarchiveDirectory()
        let webarchviePath = FileManagerAdaptor.webarchivePath(withName: fileName)
        let shouldBe = "\(webarchiveDir!)/\(fileName)"
        print("path : \(webarchviePath!), should be : \(shouldBe)")
        XCTAssert(webarchviePath! == shouldBe, "webarchive path should be correct")
    }
}
