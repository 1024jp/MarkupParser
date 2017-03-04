//
//  StyledString.swift
//  
//
//  Created by 1024jp on 2017/03/04.
//
//

public struct StyledString {
    
    let string: String
    let styles: [Style]
    
    
    public struct Style {
        
        let range: Range<String.Index>
        let type: Type
        
        
        public enum `Type` {
            
            case bold
            case strike
            case link(url: String)
            case image(url: String)
        }
    }
    
}
