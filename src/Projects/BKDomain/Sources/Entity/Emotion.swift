// Copyright © 2025 Booket. All rights reserved

public enum Emotion: String, CaseIterable, Decodable {
    case warmth = "따뜻함"
    case joy = "즐거움"
    case sad = "슬픔"
    case insight = "깨달음"
    case other = "기타"
}

public enum SubEmotion: String, CaseIterable {
    // 따뜻함
    case comforted = "위로받은"
    case cozy = "포근한"
    case tender = "다정한"
    case grateful = "고마운"
    case relieved = "마음이 놓이는"
    case peaceful = "편안한"

    // 즐거움
    case excited = "설레는"
    case satisfied = "뿌듯한"
    case cheerful = "유쾌한"
    case joyful = "기쁜"
    case thrilling = "흥미진진한"

    // 슬픔
    case hollow = "허무한"
    case lonely = "외로운"
    case regretful = "아쉬운"
    case stunned = "먹먹한"
    case bittersweet = "애틋한"
    case pitiful = "안타까운"
    case nostalgic = "그리운"

    // 깨달음
    case amazed = "감탄한"
    case insightful = "통찰력을 얻은"
    case inspired = "영감을 받은"
    case deepened = "생각이 깊어진"
    case understood = "새롭게 이해한"

    public static func subEmotions(for emotion: Emotion) -> [SubEmotion] {
        switch emotion {
        case .warmth:
            return [.comforted, .cozy, .tender, .grateful, .relieved, .peaceful]
        case .joy:
            return [.excited, .satisfied, .cheerful, .joyful, .thrilling]
        case .sad:
            return [.hollow, .lonely, .regretful, .stunned, .bittersweet, .pitiful, .nostalgic]
        case .insight:
            return [.amazed, .insightful, .inspired, .deepened, .understood]
        case .other:
            return []
        }
    }
}
