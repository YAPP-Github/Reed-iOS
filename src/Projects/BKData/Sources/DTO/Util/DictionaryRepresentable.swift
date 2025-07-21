// Copyright © 2025 Booket. All rights reserved

import Foundation

protocol DictionaryRepresentable {}

extension DictionaryRepresentable {
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            if let key = child.label {
                if let optionalValue = child.value as? OptionalProtocol {
                    if optionalValue.isNil {
                        continue
                    }
                }
                if let unwrapValue = unwrap(child.value) {
                    dict[key] = String(describing: unwrapValue)
                }
            }
        }
        return dict
    }
    
    private func unwrap(_ value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)
        if mirror.displayStyle == .optional {
            return mirror.children.first?.value
        }
        return value
    }
}

private protocol OptionalProtocol {
    var isNil: Bool { get }
}

extension Optional: OptionalProtocol {
    var isNil: Bool {
        return self == nil
    }
}
