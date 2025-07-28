// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Kingfisher
import SnapKit
import UIKit

final class SearchResultCell: UICollectionViewCell {
    struct BookDescription {
        let author: String
        let publisher: String
    }
    
    static let identifier = "SearchResultCell"

    private let resultView = BKBookSummaryView()
    private let dividerView = BKDivider(type: .small)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubviews(resultView, dividerView)

        resultView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(dividerView.snp.top)
        }

        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resultView.clearView()
    }

    func configure(
        title: String,
        description: BookDescription,
        image: URL?
    ) {
        resultView.configure(
            title: title,
            author: description.author,
            publisher: description.publisher,
            image: image
        )
    }
}
