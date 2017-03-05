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
    func stripHeadingMarks(string: String) -> String
}


public extension Parsable {

    public func parse(string: String) -> Document? {
        
        let chunks = string.components(separatedBy: .newlines)
            .flatMap { (line: String) -> Chunk? in
                guard !line.isEmpty else { return nil }
                
                if let level = self.headingLevel(string: line) {
                    return Chunk.heading(string: line, level: level)
                }
                
                return Chunk.nonHeading(string: line)
        }
        
        let section = self.createSection(chunks: chunks)
        
        return Document(rawString: string,
                        language: type(of: self).langauge,
                        section: section)
    }
    
    
    private func createSection(chunks: [Chunk], title: String? = nil, level: Int = 0) -> Section {
        
        let styledTitle: StyledString? = {
            guard let title = title else { return nil }
            return self.makeStyledString(string: title)
        }()
        var section = Section(title: styledTitle, level: level)
        
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
                
                if let rawTitle = lastTitle {
                    let title = self.stripHeadingMarks(string: rawTitle)
                    let childSection = self.createSection(chunks: childChunks,
                                                          title: title,
                                                          level: childLevel)
                    section.subsections.append(childSection)
                }
                
                childChunks = []
                lastTitle = string
                
                guard currentLevel > level else {
                    break chunkLoop
                }
                
            case .nonHeading(let string):
                if lastTitle == nil {
                    blockLines.append(string)
                } else {
                    childChunks.append(chunk)
                }
            }
        }
        
        if let rawTitle = lastTitle, !childChunks.isEmpty {
            let title = self.stripHeadingMarks(string: rawTitle)
            let childSection = self.createSection(chunks: childChunks,
                                                  title: title,
                                                  level: childLevel)
            section.subsections.append(childSection)
        }
        
        section.contents = self.makeBlocks(lines: blockLines)
        
        return section
    }

}


private enum Chunk {
    
    case heading(string: String, level: Int)
    case nonHeading(string: String)
}
