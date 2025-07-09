// Copyright © 2025 Booket. All rights reserved

import UIKit

// MARK: - Atomic Colors: 기본 색상 팔레트 정의
public enum BKAtomicColor {
    // Neutral Palette
    public enum Neutral: String {
        case n50 = "#fafafa"
        case n100 = "#f5f5f5"
        case n200 = "#e5e5e5"
        case n300 = "#d4d4d4"
        case n400 = "#a1a1a1"
        case n500 = "#737373"
        case n600 = "#525252"
        case n700 = "#404040"
        case n800 = "#262626"
        case n900 = "#171717"
        case n950 = "#0a0a0a"
        
        public var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
    
    // Common Colors
    public enum Common: String {
        case white = "#ffffff"
        case black = "#000000"
        
        public var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
    
    // Green Palette
    public enum Green: String {
        case g50 = "#f2fff6"
        case g100 = "#e3f8e9"
        case g200 = "#c1e8ca"
        case g300 = "#82c090"
        case g400 = "#40bf5d"
        case g500 = "#2f9647"
        case g600 = "#257838"
        case g700 = "#1c5a2a"
        case g800 = "#123c1c"
        case g900 = "#091d0e"
        
        public var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
    
    // Red Palette
    public enum Red: String {
        case r50 = "#ffecef"
        case r100 = "#ffced4"
        case r200 = "#f59c9d"
        case r300 = "#ed7577"
        case r400 = "#f85454"
        case r500 = "#ff443a"
        case r600 = "#f03939"
        case r700 = "#dd2f33"
        case r800 = "#d0272b"
        case r900 = "#c2191f"
        
        public var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
    
    // Yellow Palette
    public enum Yellow: String {
        case y50 = "#fff8e0"
        case y100 = "#ffedb0"
        case y200 = "#ffe17c"
        case y300 = "#ffd743"
        case y400 = "#ffcc00"
        case y500 = "#ffc300"
        case y600 = "#ffb500"
        case y700 = "#ffa100"
        case y800 = "#ff8f00"
        case y900 = "#ff6d00"
        
        public var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
    
    // Blue Palette
    public enum Blue: String {
        case b50 = "#e3f4ff"
        case b100 = "#bbe2ff"
        case b200 = "#8dd0ff"
        case b300 = "#56bdff"
        case b400 = "#1dadff"
        case b500 = "#009eff"
        case b600 = "#008fff"
        case b700 = "#007bff"
        case b800 = "#1269ec"
        case b900 = "#1f47cd"
        
        public var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
}
