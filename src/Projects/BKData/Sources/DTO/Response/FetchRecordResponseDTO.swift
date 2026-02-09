// Copyright © 2025 Booket. All rights reserved

import BKDomain

struct FetchRecordResponseDTO: Decodable {
    let readingRecords: [DetailRecordV2ResponseDTO]
    let lastPage: Bool
    let totalResults: Int
    let representativeEmotion: PrimaryEmotionResponseDTO?
}
