//
//  StyledString.swift
//  
//
//  Created by 1024jp on 2017/03/04.
//
//

struct StyledString {
    
    let string: String
    let styles: [Style]
}


struct Style {
    
    let range: Range<String.Index>
    let type: Type
    
    
    enum Type {
        
        case bold
        case strike
        case link(url: String)
        case image(url: String)
    }
}
