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
        case g200 = "#c4eccd"
        case g300 = "#9ce0ad"
        case g400 = "#6bd184"
        case g500 = "#3bc25b"
        case g600 = "#33a94f"
        case g700 = "#247938"
        case g800 = "#174822"
        case g900 = "#07180b"
        
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
        case b50 = "#EBF3FF"
        case b100 = "#C0D8FF"
        case b200 = "#94BDFF"
        case b300 = "#68A3FF"
        case b400 = "#3C88FF"
        case b500 = "#2A74E9"
        case b600 = "#195CC7"
        case b700 = "#0B47A5"
        case b800 = "#013383"
        case b900 = "#002661"
        
        public var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
    
    public enum Orange: String {
        case o50 = "#FFF1EB"
        case o100 = "#FFD2BE"
        case o200 = "#FFB392"
        case o300 = "#FF9365"
        case o400 = "#EF6D35"
        case o500 = "#CD5622"
        case o600 = "#AB4114"
        case o700 = "#892F08"
        case o800 = "#672001"
        case o900 = "#451500"
        
        public var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
    
    public enum Violet: String {
        case v50 = "#F7F0FF"
        case v100 = "#E6CEFF"
        case v200 = "#D4ADFF"
        case v300 = "#C38CFF"
        case v400 = "#B26AFF"
        case v500 = "#9A55E4"
        case v600 = "#7F40C2"
        case v700 = "#652EA0"
        case v800 = "#4C1E7E"
        case v900 = "#36125C"
        
        public var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }
}
