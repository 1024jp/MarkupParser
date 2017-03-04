//
//  StyledString.swift
//  
//
//  Created by 1024jp on 2017/03/04.
//
//

public struct StyledString {
    
    public let string: String
    public let styles: [Style]
    
    
    public struct Style {
        
        public let range: Range<String.Index>
        public let type: Type
        
        
        public enum `Type` {
            
            case bold
            case strike
            case link(url: String)
            case image(url: String)
        }
    }
    
}
