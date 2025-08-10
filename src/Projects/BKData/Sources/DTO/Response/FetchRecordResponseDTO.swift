// Copyright © 2025 Booket. All rights reserved

import BKDomain

struct FetchRecordResponseDTO: Decodable {
    let readingRecords: [DetailRecordResponseDTO]
}
