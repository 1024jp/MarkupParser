//
//  Model.swift
//  
//
//  Created by 1024jp on 2017/03/04.
//
//

public struct Document {
    
    public let rawString: String
    public let language: String
    
    public let section: Section
    
}


public struct Section {
    
    public let title: StyledString?
    public let level: Int
    public var contents: [Block]
    public var subsections: [Section]
    
    
    init(title: StyledString?, level: Int) {
        self.title = title
        self.level = level
        self.contents = []
        self.subsections = []
    }
    
}


public enum Block {
    
    case paragraph(attributedString: StyledString)
    case list(list: [StyledString])
    case code(language: String?, content: String)
    case table(string: String)
}
