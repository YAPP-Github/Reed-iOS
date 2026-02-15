// Copyright © 2025 Booket. All rights reserved

import BKDomain

struct NoteForm: Equatable {
    let page: Int?
    let sentence: String
    let memo: String?
    let primaryEmotion: PrimaryEmotion
    let detailEmotions: [DetailEmotion]
}

extension NoteForm {
    static func makeNoteForm(from forms: [RegistrationForm]) -> NoteForm? {
        var page: Int?
        var sentence: String?
        var memo: String?
        var primaryEmotion: PrimaryEmotion?
        var detailEmotions: [DetailEmotion] = []

        for form in forms {
            switch form {
            case .sentence(let s):
                page = s.page
                sentence = s.sentence
                memo = s.memo
            case .emotion(let e):
                primaryEmotion = e.primaryEmotion
                detailEmotions = e.detailEmotions
            }
        }

        guard let finalSentence = sentence,
              let finalPrimaryEmotion = primaryEmotion else {
            return nil
        }

        return NoteForm(
            page: page,
            sentence: finalSentence,
            memo: memo,
            primaryEmotion: finalPrimaryEmotion,
            detailEmotions: detailEmotions
        )
    }

    func toRecordVO() -> RecordVO {
        return RecordVO(
            pageNumber: page,
            quote: sentence,
            memo: memo,
            primaryEmotion: primaryEmotion,
            detailEmotionIds: detailEmotions.map { $0.id }
        )
    }
}
