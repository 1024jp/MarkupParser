//
//  ParserProtocol.swift
//  
//
//  Created by 1024jp on 2017/03/04.
//
//


import Foundation

public struct Heading {
    
    let string: String
    let level: Int
}

public enum Chunk {
    case heading(string: String, level: Int)
    case nonHeading(string: String)
}




public protocol Parsable {
    
    static var langauge: String { get }
    
    func makeBlocks(lines: [String]) -> [Block]
    func makeStyledString(string: String) -> StyledString
    func headingLevel(string: String) -> Int?
}


extension Parsable {

    func parse(string: String) -> Document {
        
        let lines = string.components(separatedBy: .newlines)
        
        let chunks = lines.enumerated()
            .flatMap { (index: Int, line: String) -> Chunk? in
                guard line.isEmpty else { return nil }
                
                if let level = self.headingLevel(string: line) {
                    
                    return Chunk.heading(string: string, level: level)
                }
                
                return Chunk.nonHeading(string: string)
        }
        
        let section = self.createSection(chunks: chunks)
        
        return Document(rawString: string,
                        langauge: self.langauge,
                        sectioin: section)
    }
    

}
