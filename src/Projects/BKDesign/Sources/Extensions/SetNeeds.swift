// Copyright © 2025 Booket. All rights reserved

import Foundation
import UIKit

@propertyWrapper
public struct SetNeeds<Value: Equatable> {
    enum Need {
        case layout
        case display
    }
    
    private var value: Value
    private let needs: Set<Need>
    private weak var view: UIView?
    
    // 초기화
    init(wrappedValue: Value, _ needs: Need...) {
        self.value = wrappedValue
        self.needs = Set(needs)
        self.view = nil
    }
    
    // 실제 값에 접근할 때 사용되는 프로퍼티
    public var wrappedValue: Value {
        get { value }
        set {
            let oldValue = value
            value = newValue
            
            // 값이 변경되었을 때만 UI 업데이트
            if oldValue != newValue {
                updateView()
            }
        }
    }
    
    // 뷰를 설정하는 메서드
    mutating func configure(with view: UIView) {
        self.view = view
    }
    
    private func updateView() {
        guard let view = view else { return }
        
        // needs에 따라 적절한 메서드 호출
        if needs.contains(.layout) {
            view.setNeedsLayout()  // 레이아웃 재계산 필요
        }
        if needs.contains(.display) {
            view.setNeedsDisplay()  // 다시 그리기 필요
        }
    }
}
