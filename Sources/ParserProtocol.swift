//
//  ParserProtocol.swift
//  
//
//  Created by 1024jp on 2017/03/04.
//
//


import Foundation

struct Heading {
    
    let string: String
    let level: Int
}

enum Chunk {
    case heading(string: String, level: Int)
    case nonHeading(string: String)
}




protocol Parsable {
    
    var langauge: String { get }
    
    func parse(string: String) -> Document
    
    func makeBlocks(lines: [String]) -> [Block]
    func makeStyledString(string: String) -> StyledString
    func headingLevel(string: String) -> Int?
}


