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
        
        guard let range = string.range(of: "^#+", options: .regularExpression)
            else { return nil }
        
        return string.substring(with: range).characters.count
    }
    
    func stripHeadingMarks(string: String) -> String {
        
        return string.replacingOccurrences(of: "^#+ *", with: "", options: .regularExpression)
    }
}

class MarkupParserTests: XCTestCase {
    
    func testSwiftMarkdown() {
        
        let bundle = Bundle(for: type(of: self))
        let url = bundle.url(forResource: "test.md", withExtension: "")!
        let string = try! String(contentsOf: url)
        
        let parser = MockParser()
        
        let document = parser.parse(string: string)!
        
        XCTAssertEqual(document.rawString, string)
        
        XCTAssertEqual(document.section.contents.count, 1)
        XCTAssertEqual(document.section.subsections.count, 1)
        
        let section = document.section.subsections.first!
        XCTAssertEqual(section.contents.count, 1)
        XCTAssertEqual(section.subsections.count, 5)
        XCTAssertEqual(section.subsections[2].contents.first!.string!.characters.count, 308)
    }
    
    
    func getString(block: Block) -> String? {
        
        switch block {
        case .paragraph(let string):
            return string.string
        default:
            return nil
        }
    }
    
    
    func testExample() {
        
        let source = "hey\n# hello\nmy friend\n## gayan\nhello"
        let parser = MarkupParser()
        
        let document = parser.parse(string: source)!
        
        XCTAssertEqual(document.language, "Markdown")
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


extension Block {
    
    var string: String? {
        
        switch self {
        case .paragraph(let string):
            return string.string
        default:
            return nil
        }
    }
}
