// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

struct BookDetailItem: Hashable {
    let id: String // book id임
    let recordId: String
    /// 수집한 문장
    let note: String
    /// 감정
    let emotion: EmotionSeed?
    let createdAt: Date
    let page: Int?
    let bookTitle: String
    
    static func from(recordInfo: RecordInfo) -> Self {
        return Self(
            id: recordInfo.bookId,
            recordId: recordInfo.recordId,
            note: recordInfo.quote,
            emotion: EmotionSeed.from(emotion: recordInfo.emotionTags.first ?? .joy),
            createdAt: recordInfo.createdAt,
            page: recordInfo.pageNumber,
            bookTitle: recordInfo.bookTitle
        )
    }
}
