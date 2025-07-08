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
    
    // 각 스타일의 실제 속성을 정의합니다.
    public var fontAttributes: (fontName: BKFontName, fontSize: BKFontSize, lineHeight: BKLineHeight, letterSpacing: BKLetterSpacing?) {
        switch self {
            
        case .title1(let weight):
            switch weight {
            case .bold: return (.pretendardBold, .pt28, .percent135_8, .percentNegative2_36)
            case .semiBold: return (.pretendardSemiBold, .pt28, .percent135_8, .percentNegative2_36)
            case .medium: return (.pretendardMedium, .pt28, .percent135_8, .percentNegative2_3)
            default: return (.pretendardRegular, .pt28, .percent135_8, .percentNegative2_3)
            }
        case .title2(let weight):
            switch weight {
            case .semiBold: return (.pretendardSemiBold, .pt24, .percent134_4, .percentNegative2_3)
            default: return (.pretendardRegular, .pt24, .percent134_4, .percentNegative2_3)
            }
            
        
        case .heading1(let weight):
            switch weight {
            case .bold: return (.pretendardBold, .pt22, .percent136_4, .percentNegative1_2)
            case .semiBold: return (.pretendardSemiBold, .pt22, .percent136_4, .percentNegative1_2)
            default: return (.pretendardRegular, .pt22, .percent136_4, .percentNegative1_2)
            }
        case .heading2(let weight):
            switch weight {
            case .semiBold: return (.pretendardSemiBold, .pt20, .percent140, .percentNegative1_2)
            default: return (.pretendardRegular, .pt20, .percent140, .percentNegative1_2)
            }
            
        
        case .headline1(let weight):
            switch weight {
            case .semiBold: return (.pretendardSemiBold, .pt18, .percent144_5, .percentNegative1_2)
            default: return (.pretendardRegular, .pt18, .percent144_5, .percentNegative1_2)
            }
        case .headline2(let weight):
            switch weight {
            case .semiBold: return (.pretendardSemiBold, .pt17, .percent141_2, .percentNegative1)
            case .medium: return (.pretendardMedium, .pt17, .percent141_2, .percentNegative1)
            default: return (.pretendardRegular, .pt17, .percent141_2, .percentNegative1)
            }
            
        
        case .body1(let weight):
            switch weight {
            case .bold: return (.pretendardBold, .pt16, .percent162_5, .percentNegative1)
            case .semiBold: return (.pretendardSemiBold, .pt16, .percent162_5, .percentNegative1)
            case .medium: return (.pretendardMedium, .pt16, .percent150, .percentNegative1)
            case .regular: return (.pretendardRegular, .pt16, .percent150, .percentNegative1)
            }
        case .body2(let weight):
            switch weight {
            case .medium: return (.pretendardMedium, .pt15, .percent146_7, .percentNegative1)
            case .regular: return (.pretendardRegular, .pt15, .percent160, .percentNegative1)
            default: return (.pretendardRegular, .pt15, .percent160, .percentNegative1)
            }
            
        
        case .label1(let weight):
            switch weight {
            case .semiBold: return (.pretendardSemiBold, .pt14, .percent142_9, .percentNegative1)
            case .medium: return (.pretendardMedium, .pt14, .percent157_1, .percentNegative1)
            default: return (.pretendardRegular, .pt14, .percent142_9, .percentNegative1)
            }
        case .label2(let weight):
            switch weight {
            case .semiBold: return (.pretendardSemiBold, .pt13, .percent138_5, .percentNegative1)
            case .regular: return (.pretendardRegular, .pt13, .percent138_5, .percentNegative1)
            default: return (.pretendardRegular, .pt13, .percent138_5, .percentNegative1)
            }
            
        
        case .caption1(let weight):
            switch weight {
            case .regular: return (.pretendardRegular, .pt12, .percent133_4, .percentNegative1)
            default: return (.pretendardRegular, .pt12, .percent133_4, .percentNegative1)
            }
        case .caption2(let weight):
            switch weight {
            case .regular: return (.pretendardRegular, .pt11, .percent127_3, .percentNegative1)
            default: return (.pretendardRegular, .pt11, .percent127_3, .percentNegative1)
            }
        }
    }
    
    public var uiFont: UIFont? {
        let (fontName, fontSize, _, _) = fontAttributes
        return UIFont(name: fontName.rawValue, size: fontSize.rawValue)
    }
    
    public var paragraphStyle: NSMutableParagraphStyle {
        let (_, fontSize, lineHeight, _) = fontAttributes
        let paragraphStyle = NSMutableParagraphStyle()
        
        let actualLineHeight = lineHeight.calculateAbsoluteLineHeight(for: fontSize.rawValue)
        paragraphStyle.minimumLineHeight = actualLineHeight
        paragraphStyle.maximumLineHeight = actualLineHeight
        
        return paragraphStyle
    }
    
    public func attributedString(from text: String, color: UIColor = .label) -> NSAttributedString {
        let (_, fontSize, _, letterSpacing) = fontAttributes
        
        var attributes: [NSAttributedString.Key: Any] = [
            .font: uiFont ?? UIFont.systemFont(ofSize: fontSize.rawValue),
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]
        
        if let letterSpacing = letterSpacing {
            let actualLetterSpacing = letterSpacing.calculateAbsoluteLetterSpacing(for: fontSize.rawValue)
            attributes[.kern] = actualLetterSpacing
        }
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}


