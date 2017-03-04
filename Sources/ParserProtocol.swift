//
//  ParserProtocol.swift
//  
//
//  Created by 1024jp on 2017/03/04.
//
//

public protocol Parsable {
    
    static var langauge: String { get }
    
    func makeBlocks(lines: [String]) -> [Block]
    func makeStyledString(string: String) -> StyledString
    func headingLevel(string: String) -> Int?
}


extension Parsable {

    func parse(string: String) -> Document {
        
        let chunks = string.components(separatedBy: .newlines)
            .flatMap { (line: String) -> Chunk? in
                guard !line.isEmpty else { return nil }
                
                if let level = self.headingLevel(string: line) {
                    
                    return Chunk.heading(string: string, level: level)
                }
                
                return Chunk.nonHeading(string: string)
        }
        
        let section = self.createSection(chunks: chunks)
        
        return Document(rawString: string,
                        language: type(of: self).langauge,
                        section: section)
    }
    
    
    
    func createSection(chunks: [Chunk], title: StyledString? = nil, level: Int = 0) -> Section {
        
        var section = Section(title: title, level: level)
        
        var blockLines = [String]()
        var lastTitle: String?
        var childChunks = [Chunk]()
        let childLevel = level + 1
        
        chunkLoop: for chunk in chunks {
            switch chunk {
            case .heading(let string, let currentLevel):
                if currentLevel > childLevel {
                    childChunks.append(chunk)
                    continue
                }
                
                if let title = lastTitle {
                    let styledTitle = self.makeStyledString(string: title)
                    let childSection = self.createSection(chunks: childChunks,
                                                          title: styledTitle,
                                                          level: childLevel)
                    section.subsections.append(childSection)
                }
                
                childChunks = []
                lastTitle = string
                
                guard currentLevel < level else {
                    break chunkLoop
                }
                
            case .nonHeading(let string):
                if childChunks.isEmpty {
                    blockLines.append(string)
                } else {
                    childChunks.append(chunk)
                }
            }
        }
        
        
        if let title = lastTitle {
            let styledTitle = self.makeStyledString(string: title)
            let childSection = self.createSection(chunks: childChunks,
                                                  title: styledTitle,
                                                  level: childLevel)
            section.subsections.append(childSection)
        }
        
        section.contents = self.makeBlocks(lines: blockLines)
        
        return section
    }

}


enum Chunk {
    
    case heading(string: String, level: Int)
    case nonHeading(string: String)
}
