//
//  ContentLayout.swift
//  r2-shared-swift
//
//  Created by Alexandre Camilleri, Mickaël Menu on 13.03.19.
//
//  Copyright 2019 Readium Foundation. All rights reserved.
//  Use of this source code is governed by a BSD-style license which is detailed
//  in the LICENSE file present in the project repository where this source code is maintained.
//

import Foundation


public enum ReadingProgression: String {
    case rtl
    case ltr
    case auto
    
    /// Returns the leading Page for the reading progression.
    public var leadingPage: Properties.Page {
        switch self {
        case .ltr, .auto:
            return .left
        case .rtl:
            return .right
        }
    }
}


public enum ContentLayoutStyle: String {
    case rtl = "rtl"
    case ltr = "ltr"
    case cjkVertical = "cjk-vertical"
    case cjkHorizontal = "cjk-horizontal"

    public init(language: String, readingProgression: ReadingProgression? = nil) {
        let language: String = {
            if let code = language.split(separator: "-").first {
                return String(code)
            }
            return language
        }()
        
        self = .ltr
                
// Commented due to weird bug with messing across multiple language inside books metadata

//        switch language.lowercased() {
//        case "ar", "fa", "he":
//            self = .rtl
//        // Any Chinese: zh-*-*
//        case "zh", "ja", "ko":
//            self = (readingProgression == .rtl) ? .cjkVertical : .cjkHorizontal
//        default:
//            self = (readingProgression == .rtl) ? .rtl : .ltr
//        }
    }
    
    public var readingProgression: ReadingProgression {
        switch self {
        case .rtl, .cjkVertical:
            return .rtl
        case .ltr, .cjkHorizontal:
            return .ltr
        }
    }

}
