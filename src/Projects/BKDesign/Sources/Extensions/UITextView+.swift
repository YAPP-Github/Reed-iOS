// Copyright © 2025 Booket. All rights reserved

import UIKit

extension UITextView {
    func moveCaretToStartOfLastLine() {
        let dir = UITextStorageDirection.backward.rawValue
        if let lineRange = tokenizer.rangeEnclosingPosition(endOfDocument, with: .line, inDirection: UITextDirection(rawValue: dir)) {
            selectedTextRange = textRange(from: lineRange.start, to: lineRange.start)
        }
    }
}
