// Copyright © 2025 Booket. All rights reserved

@testable import BKDomain
import Nimble
import Quick
import XCTest

// XCTestCase 대신 QuickSpec을 상속합니다.
final class BDDExampleTest: QuickSpec {
    // QuickSpec에서는 setUp/tearDown 대신 spec() 메서드 안에서 테스트를 정의합니다.
    override class func spec() {
        // describe: 테스트 대상이 되는 시스템 또는 컴포넌트를 설명합니다.
        describe("테스트 대상이") {
            
            beforeEach {
                // beforeEach: 각 `it` 또는 `context` 블록이 실행되기 전에 수행할 설정을 정의합니다.
            }
            
            // context: 특정 시나리오나 상태를 설명합니다.
            context("어떤 상황에서") {
                // it: 테스트할 개별 행위 또는 기대를 설명합니다.
                it("예상되는 행위 1") {
                    // Nimble의 expect와 매처를 사용하여 단언합니다.
                    // assertion
                    // expect(<#T##expression: T?##T?#>).to(<#T##matcher: Matcher<_>##Matcher<_>#>)
                }
                
                it("예상되는 행위 2") {
                    
                }
            }
        }
    }

}
