//
//  Model.swift
//  
//
//  Created by 1024jp on 2017/03/04.
//
//

struct Document {
    
    let rawString: String
    let language: Language
    
    let sections: [Section]
    
}

struct Section {
    
    let title: StyledString?
    let level: Int
    let contents: [Block]
    let subsections: [Section]
}


enum Block {
    
    case paragraph(attributedString: StyledString)
    case list(list: [StyledString])
    case code(language: String?, content: String)
}
