//
//  Model.swift
//  
//
//  Created by 1024jp on 2017/03/04.
//
//

public struct Document {
    
    let rawString: String
    let language: String
    
    let section: Section
    
}

public struct Section {
    
    let title: StyledString?
    let level: Int
    var contents: [Block]
    var subsections: [Section]
    
    
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
