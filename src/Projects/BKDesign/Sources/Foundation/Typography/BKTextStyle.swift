// Copyright © 2025 Booket. All rights reserved

import UIKit

// MARK: - BKTextStyle: 타이포그래피 스타일 정의
public enum BKTextStyle {
    // Title 그룹
    case title1(weight: BKFontWeight)
    case title2(weight: BKFontWeight)
    
    // Heading 그룹
    case heading1(weight: BKFontWeight)
    case heading2(weight: BKFontWeight)
    
    // Headline 그룹
    case headline1(weight: BKFontWeight)
    case headline2(weight: BKFontWeight)
    
    // Body 그룹
    case body1(weight: BKFontWeight)
    case body2(weight: BKFontWeight)
    
    // Label 그룹
    case label1(weight: BKFontWeight)
    case label2(weight: BKFontWeight)
    
    // Caption 그룹
    case caption1(weight: BKFontWeight)
    case caption2(weight: BKFontWeight)
    
    // MARK: - fontAttributes: 폰트 속성 구조체 반환
    public var fontAttributes: BKFontAttributes {
        switch self {
        // Title
        case .title1(let weight):
            switch weight {
            case .bold:
                return BKFontAttributes(fontName: .pretendardBold, fontSize: .pt28, lineHeight: .p135_8, letterSpacing: .pNegative2_36)
            case .semiBold:
                return BKFontAttributes(fontName: .pretendardSemiBold, fontSize: .pt28, lineHeight: .p135_8, letterSpacing: .pNegative2_36)
            case .medium:
                return BKFontAttributes(fontName: .pretendardMedium, fontSize: .pt28, lineHeight: .p135_8, letterSpacing: .pNegative2_3)
            default:
                return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt28, lineHeight: .p135_8, letterSpacing: .pNegative2_3)
            }
        case .title2(let weight):
            switch weight {
            case .semiBold: return BKFontAttributes(fontName: .pretendardSemiBold, fontSize: .pt24, lineHeight: .p134_4, letterSpacing: .pNegative2_3)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt24, lineHeight: .p134_4, letterSpacing: .pNegative2_3)
            }
            
        // Heading
        case .heading1(let weight):
            switch weight {
            case .bold: return BKFontAttributes(fontName: .pretendardBold, fontSize: .pt22, lineHeight: .p136_4, letterSpacing: .pNegative1_2)
            case .semiBold: return BKFontAttributes(fontName: .pretendardSemiBold, fontSize: .pt22, lineHeight: .p136_4, letterSpacing: .pNegative1_2)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt22, lineHeight: .p136_4, letterSpacing: .pNegative1_2)
            }
        case .heading2(let weight):
            switch weight {
            case .semiBold: return BKFontAttributes(fontName: .pretendardSemiBold, fontSize: .pt20, lineHeight: .p140, letterSpacing: .pNegative1_2)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt20, lineHeight: .p140, letterSpacing: .pNegative1_2)
            }
            
        // Headline
        case .headline1(let weight):
            switch weight {
            case .semiBold: return BKFontAttributes(fontName: .pretendardSemiBold, fontSize: .pt18, lineHeight: .p144_5, letterSpacing: .pNegative1_2)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt18, lineHeight: .p144_5, letterSpacing: .pNegative1_2)
            }
        case .headline2(let weight):
            switch weight {
            case .semiBold: return BKFontAttributes(fontName: .pretendardSemiBold, fontSize: .pt17, lineHeight: .p141_2, letterSpacing: .pNegative1)
            case .medium: return BKFontAttributes(fontName: .pretendardMedium, fontSize: .pt17, lineHeight: .p141_2, letterSpacing: .pNegative1)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt17, lineHeight: .p141_2, letterSpacing: .pNegative1)
            }
            
        // Body
        case .body1(let weight):
            switch weight {
            case .bold: return BKFontAttributes(fontName: .pretendardBold, fontSize: .pt16, lineHeight: .p162_5, letterSpacing: .pNegative1)
            case .semiBold: return BKFontAttributes(fontName: .pretendardSemiBold, fontSize: .pt16, lineHeight: .p162_5, letterSpacing: .pNegative1)
            case .medium: return BKFontAttributes(fontName: .pretendardMedium, fontSize: .pt16, lineHeight: .p150, letterSpacing: .pNegative1)
            case .regular: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt16, lineHeight: .p150, letterSpacing: .pNegative1)
            }
        case .body2(let weight):
            switch weight {
            case .medium: return BKFontAttributes(fontName: .pretendardMedium, fontSize: .pt15, lineHeight: .p146_7, letterSpacing: .pNegative1)
            case .regular: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt15, lineHeight: .p160, letterSpacing: .pNegative1)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt15, lineHeight: .p160, letterSpacing: .pNegative1)
            }
            
        // Label
        case .label1(let weight):
            switch weight {
            case .semiBold: return BKFontAttributes(fontName: .pretendardSemiBold, fontSize: .pt14, lineHeight: .p142_9, letterSpacing: .pNegative1)
            case .medium: return BKFontAttributes(fontName: .pretendardMedium, fontSize: .pt14, lineHeight: .p157_1, letterSpacing: .pNegative1)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt14, lineHeight: .p142_9, letterSpacing: .pNegative1)
            }
        case .label2(let weight):
            switch weight {
            case .semiBold: return BKFontAttributes(fontName: .pretendardSemiBold, fontSize: .pt13, lineHeight: .p138_5, letterSpacing: .pNegative1)
            case .regular: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt13, lineHeight: .p138_5, letterSpacing: .pNegative1)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt13, lineHeight: .p138_5, letterSpacing: .pNegative1)
            }
            
        // Caption
        case .caption1(let weight):
            switch weight {
            case .regular: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt12, lineHeight: .p133_4, letterSpacing: .pNegative1)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt12, lineHeight: .p133_4, letterSpacing: .pNegative1)
            }
        case .caption2(let weight):
            switch weight {
            case .regular: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt11, lineHeight: .p127_3, letterSpacing: .pNegative1)
            default: return BKFontAttributes(fontName: .pretendardRegular, fontSize: .pt11, lineHeight: .p127_3, letterSpacing: .pNegative1)
            }
        }
    }
    
    public var uiFont: UIFont? {
        return UIFont(name: fontAttributes.fontName.rawValue, size: fontAttributes.fontSize.rawValue)
    }
    
    public var paragraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        
        let actualLineHeight = fontAttributes.lineHeight.calculateAbsoluteLineHeight(for: fontAttributes.fontSize.rawValue)
        paragraphStyle.minimumLineHeight = actualLineHeight
        paragraphStyle.maximumLineHeight = actualLineHeight
        
        return paragraphStyle
    }
    
    public func attributedString(from text: String, color: UIColor = .label) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: uiFont ?? UIFont.systemFont(ofSize: fontAttributes.fontSize.rawValue),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        
        if let letterSpacing = fontAttributes.letterSpacing {
            let actualLetterSpacing = letterSpacing.calculateAbsoluteLetterSpacing(for: fontAttributes.fontSize.rawValue)
            attributes[.kern] = actualLetterSpacing
        }
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}

// MARK: - BKFontAttributes: 폰트의 모든 속성을 담는 구조체
public struct BKFontAttributes {
    public let fontName: BKFontName
    public let fontSize: BKFontSize
    public let lineHeight: BKLineHeight
    public let letterSpacing: BKLetterSpacing?

    public init(fontName: BKFontName, fontSize: BKFontSize, lineHeight: BKLineHeight, letterSpacing: BKLetterSpacing?) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
    }
}
