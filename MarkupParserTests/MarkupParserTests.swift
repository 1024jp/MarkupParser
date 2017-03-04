//
//  MarkupParserTests.swift
//  MarkupParserTests
//
//  Created by 史翔新 on 2017/03/04.
//  Copyright © 2017年 Crazism. All rights reserved.
//

import XCTest
@testable import MarkupParser

class MockParser: Parsable {
    
    static let langauge = "Mock"
    
    func makeBlocks(lines: [String]) -> [Block] {
        let atttString = lines.joined(separator: "\n")
        let block = Block.paragraph(attributedString: StyledString(string: atttString,
                                                       styles: []))
        return [block]
    }
    
    func makeStyledString(string: String) -> StyledString {
        
        return StyledString(string: string, styles: [])
    }
    
    func headingLevel(string: String) -> Int? {
        
        return string.hasPrefix("#") ? 1 : nil
    }
    
    func stripHeadingMarks(string: String) -> String {
        
        return string.replacingOccurrences(of: "^#+ *", with: "", options: .regularExpression)
    }
}

class MarkupParserTests: XCTestCase {
    
    func testExample() {
        
        let source = "hey\n# hello\nmy friend"
        let parser = MockParser()
        
        let document = parser.parse(string: source)!
        
        XCTAssertEqual(document.language, "Mock")
        XCTAssertEqual(document.rawString, source)
        
        let section = document.section
        
        XCTAssertNil(section.title)
        XCTAssertEqual(section.level, 0)
        XCTAssertEqual(section.contents.count, 1)
        let content = section.contents.first!
        switch content {
        case .paragraph(attributedString: let string):
            XCTAssertEqual(string.string, "hey")
        default:
            fatalError()
        }
        XCTAssertEqual(section.subsections.count, 1)
        XCTAssertEqual(section.subsections.first!.title!.string, "hello")
        
        
        
    }
    
}
