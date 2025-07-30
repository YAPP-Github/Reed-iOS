// Copyright © 2025 Booket. All rights reserved

import Foundation

struct NoteForm: Equatable {
    let page: String
    let sentence: String
    let emotion: Emotion
    let appreciation: String
}
    
extension NoteForm {
    static func makeNoteForm(from forms: [RegistrationForm]) -> NoteForm? {
        var page: String?
        var sentence: String?
        var emotion: Emotion?
        var appreciation: String?

        for form in forms {
            switch form {
            case .sentence(let s):
                page = s.page
                sentence = s.sentence
            case .emotion(let e):
                emotion = e.emotion
            case .appreciation(let a):
                appreciation = a.appreciation
            }
        }
        
        guard let finalPage = page,
              let finalSentence = sentence,
              let finalEmotion = emotion,
              let finalAppreciation = appreciation else {
            return nil
        }

        return NoteForm(
            page: finalPage,
            sentence: finalSentence,
            emotion: finalEmotion,
            appreciation: finalAppreciation
        )
    }
}
