//
//  FileManagerAdaptor.swift
//  BlogFamily
//
//  Created by huangluyang on 16/5/25.
//  Copyright © 2016年 huangluyang. All rights reserved.
//

import Foundation
import SwiftFilePath

struct FileManagerAdaptor {
    static let documentsDirectory = Path.documentsDir.toString()
    
    static func relativeDirectoryToDocuments(withName name: String) -> String? {
        let path = Path.documentsDir[name]
        if path.mkdir().isSuccess {
            return path.toString()
        } else {
            return nil
        }
    }
}

extension FileManagerAdaptor {
    static func webarchiveDirectory() -> String? {
        return relativeDirectoryToDocuments(withName: "webarchives")
    }
    
    static func generateWebarchiveId() -> String {
        return NSUUID().UUIDString
    }
    
    static func generateWebarchiveName() -> String {
        return "\(NSUUID().UUIDString).webarchive"
    }
    
    static func fileName(withWebarhiveId arhiveId: String) -> String {
        return "\(arhiveId).webarchive"
    }
    
    static func webarchiveId(withFileName fileName: String) -> String? {
        let fileExt = ".webarchive"
        guard fileName.hasSuffix(fileExt) else {
            return nil
        }
        
        return fileName.substringToIndex(fileName.rangeOfString(fileExt)!.startIndex)
    }
    
    static func webarchivePath(withName name: String) -> String? {
        guard let dir = webarchiveDirectory() else {
            return nil
        }
        return "\(dir)/\(name)"
    }
}
