//
//  MarkupParser.swift
//  MarkupParser
//
//  Created by 史翔新 on 2017/03/04.
//
//

import Foundation

class MarkupParser: Parsable {
	
	static let langauge: String = "Markup"
	
	func makeBlocks(lines: [String]) -> [Block] {
		
		return []
		
	}
	
	func makeStyledString(string: String) -> StyledString {
		
		var plainString = String.empty
		var styles: [StyledString.Style] = []
		
		var checkingStart = string.startIndex
		
		while let styleStart = string.getStyledStringMarkupStart(after: checkingStart) {
			
			switch styleStart.character {
			case "*":
				let preToken = string.substring(to: styleStart.position)
				let token = string.substring(from: styleStart.position)
				
				if let boldStrikeRange = token.getBoldStrikeRange() {
					let boldStrikeString = token.substring(with: boldStrikeRange)
					let plainedBoldStrikeString = boldStrikeString.retrievePlainStringFromBoldStrikeString()
					plainString.append(preToken)
					
					let styleRangeStart = plainString.endIndex
					plainString.append(plainedBoldStrikeString)
					let styleRangeEnd = plainString.endIndex
					let styleRange = styleRangeStart ..< styleRangeEnd
					
					let boldStyle = StyledString.Style(range: styleRange, type: .bold)
					let strikeStyle = StyledString.Style(range: styleRange, type: .strike)
					styles += [boldStyle, strikeStyle]
					
					checkingStart = boldStrikeRange.upperBound
					
				} else if let boldRange = token.getBoldRange() {
					let boldString = token.substring(with: boldRange)
					let plainedBoldString = boldString.retrievePlainStringFromBoldString()
					plainString.append(preToken)
					
					let styleRangeStart = plainString.endIndex
					plainString.append(plainedBoldString)
					let styleRangeEnd = plainString.endIndex
					
					let styleRange = styleRangeStart ..< styleRangeEnd
					let boldStyle = StyledString.Style(range: styleRange, type: .bold)
					styles.append(boldStyle)
					
					checkingStart = boldRange.upperBound
					
				} else if let strikeRange = token.getStrikeRange() {
					let strikeString = token.substring(with: strikeRange)
					let plainedStrikeString = strikeString.retrievePlainStringFromStrikeString()
					plainString.append(preToken)
					
					let styleRangeStart = plainString.endIndex
					plainString.append(plainedStrikeString)
					let styleRangeEnd = plainString.endIndex
					
					let styleRange = styleRangeStart ..< styleRangeEnd
					let strikeStyle = StyledString.Style(range: styleRange, type: .strike)
					styles.append(strikeStyle)
					
					checkingStart = strikeRange.upperBound
					
				} else {
					checkingStart = string.index(after: checkingStart)
				}
				
			case "[":
				let preToken = string.substring(to: styleStart.position)
				let token = string.substring(from: styleStart.position)
				
				if let linkRange = token.getLinkRange() {
					let linkString = token.substring(with: linkRange)
					let (plainedLinkString, link) = linkString.retrievePlainStringAndLinkFromLinkString()
					plainString.append(preToken)
					
					let styleRangeStart = plainString.endIndex
					plainString.append(plainedLinkString)
					let styleRangeEnd = plainString.endIndex
					
					let styleRange = styleRangeStart ..< styleRangeEnd
					let linkStyle = StyledString.Style(range: styleRange, type: .link(url: link))
					styles.append(linkStyle)
					
					checkingStart = linkRange.upperBound
					
				} else {
					checkingStart = string.index(after: checkingStart)
				}
				
			case "![":
				let preToken = string.substring(to: styleStart.position)
				let token = string.substring(from: styleStart.position)
				
				if let imageRange = token.getImageRange() {
					let imageString = token.substring(with: imageRange)
					let (plainedImageString, image) = imageString.retrievePlainStringAndImageFromImageString()
					plainString.append(preToken)
					
					let styleRangeStart = plainString.endIndex
					plainString.append(plainedImageString)
					let styleRangeEnd = plainString.endIndex
					
					let styleRange = styleRangeStart ..< styleRangeEnd
					let imageStyle = StyledString.Style(range: styleRange, type: .image(url: image))
					styles.append(imageStyle)
					
					checkingStart = imageRange.upperBound
					
				} else {
					checkingStart = string.index(after: checkingStart)
				}
				
			default:
				checkingStart = string.index(after: checkingStart)
			}
			
		}
		
		let remainingPlainText = string.substring(from: checkingStart)
		plainString.append(remainingPlainText)
		
		let style = StyledString(string: plainString, styles: styles)
		return style
		
	}
	
	func headingLevel(string: String) -> Int? {
		
		let headerString = string.getFirstSection(separatedBy: .whitespaces)
		return headerString.headerLevel
		
	}
	
}

extension MarkupParser {
	
//	fileprivate func makeBlock(from string: String) -> Block {
//		
//	}
	
}

private extension String {
	
	static var empty: String {
		return ""
	}
	
}

private extension String {
	
	func getStyledStringMarkupStart(after index: Index) -> (position: Index, character: String)? {
		
		let styleMarkupStartSet = CharacterSet(charactersIn: "*[")
		
		guard var range = self.rangeOfCharacter(from: styleMarkupStartSet, options: [], range: index ..< self.endIndex) else {
			return nil
		}
		
		var styleMarkupStart = self.substring(with: range)
		if styleMarkupStart == "[" {
			let previousIndex = self.index(before: range.lowerBound)
			let imageRange = previousIndex ..< range.upperBound
			let imageStart = "!["
			let checkingString = self.substring(with: imageRange)
			if checkingString == imageStart {
				range = imageRange
				styleMarkupStart = imageStart
			}
		}
		
		return (range.lowerBound, styleMarkupStart)
		
	}
	
}

private extension String {
	
	static let boldStrikeExpression = "\\*\\*\\*.+\\*\\*\\*"
	
	func getBoldStrikeRange() -> Range<Index>? {
		
		let searchingString = String.boldStrikeExpression
		
		guard let range = self.range(of: searchingString, options: .regularExpression, range: nil, locale: nil), range.lowerBound == self.startIndex
		 else {
			return nil
		}
		
		return range
		
	}
	
	func retrievePlainStringFromBoldStrikeString() -> String {
		
		let lowerBound = self.index(self.startIndex, offsetBy: 3)
		let upperBound = self.index(self.endIndex, offsetBy: -3)
		return self.substring(with: lowerBound ..< upperBound)
		
	}
	
	static let boldExpression = "\\*\\*.+\\*\\*"
	
	func getBoldRange() -> Range<Index>? {
		
		let searchingString = String.boldExpression
		
		guard let range = self.range(of: searchingString, options: .regularExpression, range: nil, locale: nil), range.lowerBound == self.startIndex else {
			return nil
		}
		
		return range
		
	}
	
	func retrievePlainStringFromBoldString() -> String {
		
		let lowerBound = self.index(self.startIndex, offsetBy: 2)
		let upperBound = self.index(self.endIndex, offsetBy: -2)
		return self.substring(with: lowerBound ..< upperBound)
		
	}
	
	static let strikeExpression = "\\*.+\\*"
	
	func getStrikeRange() -> Range<Index>? {
		
		let searchingString = String.strikeExpression
		
		guard let range = self.range(of: searchingString, options: .regularExpression, range: nil, locale: nil), range.lowerBound == self.startIndex else {
			return nil
		}
		
		return range
		
	}
	
	func retrievePlainStringFromStrikeString() -> String {
		
		let lowerBound = self.index(self.startIndex, offsetBy: 1)
		let upperBound = self.index(self.endIndex, offsetBy: -1)
		return self.substring(with: lowerBound ..< upperBound)
		
	}
	
}

private extension String {
	
	static let linkExpression = "\\[.+\\]\\(.+\\)"
	
	func getLinkRange() -> Range<Index>? {
		
		let searchingString = String.linkExpression
		
		guard let range = self.range(of: searchingString, options: .regularExpression, range: nil, locale: nil), range.lowerBound == self.startIndex else {
			return nil
		}
		
		return range
		
	}
	
	func retrievePlainStringAndLinkFromLinkString() -> (string: String, link: String) {
		
		guard let separatorRange = self.range(of: "](") else {
			fatalError("Wrong call for retrievePlainStringAndLinkFromLinkString")
		}
		
		let plainStringRange = self.index(after: self.startIndex) ..< separatorRange.lowerBound
		let linkStringRange = separatorRange.upperBound ..< self.index(before: self.endIndex)
		
		let plainString = self.substring(with: plainStringRange)
		let linkString = self.substring(with: linkStringRange)
		
		return (plainString, linkString)
		
	}
	
}

private extension String {
	
	static let imageExpression = "\\!\\[.+\\]\\(.+\\)"
	
	func getImageRange() -> Range<Index>? {
		
		let searchingString = String.imageExpression
		
		guard let range = self.range(of: searchingString, options: .regularExpression, range: nil, locale: nil), range.lowerBound == self.startIndex else {
			return nil
		}
		
		return range
		
	}
	
	func retrievePlainStringAndImageFromImageString() -> (string: String, image: String) {
		
		guard let separatorRange = self.range(of: "](") else {
			fatalError("Wrong call for retrievePlainStringAndLinkFromLinkString")
		}
		
		let plainStringRange = self.index(self.startIndex, offsetBy: 2) ..< separatorRange.lowerBound
		let linkStringRange = separatorRange.upperBound ..< self.index(before: self.endIndex)
		
		let plainString = self.substring(with: plainStringRange)
		let linkString = self.substring(with: linkStringRange)
		
		return (plainString, linkString)
		
	}
	
}

private extension String {
	
	func getFirstSection(separatedBy separator: CharacterSet) -> String {
		
		guard let separatorRange = self.rangeOfCharacter(from: separator) else {
			return self
		}
		
		let firstSection = self.substring(to: separatorRange.lowerBound)
		
		return firstSection
		
	}
	
}

private extension String {
	
	var headerLevel: Int? {
		
		switch self {
		case "#":
			return 1
			
		case "##":
			return 2
			
		case "###":
			return 3
			
		case "####":
			return 4
			
		case "#####":
			return 5
			
		case "######":
			return 6
			
		default:
			return nil
		}
		
	}
	
}
