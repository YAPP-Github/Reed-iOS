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

    private var resultView: BKBookSummaryView?
    private let dividerView = BKDivider(type: .small)

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(dividerView)
        dividerView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        resultView?.clearView()
    }

    func configure(
        title: String,
        description: BookDescription,
        image: URL?,
        canSelect: Bool = true,
        recordCount: Int? = nil
    ) {
        if resultView == nil {
            let view = BKBookSummaryView(
                style: recordCount != nil ? .record : (
                    canSelect ? .regular : .alreadyEnroll
                )
            )
            
            contentView.addSubview(view)
            view.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(dividerView.snp.top)
            }
            self.resultView = view
        }
        
        resultView?.configure(
            title: title,
            author: description.author,
            publisher: description.publisher,
            recordCount: recordCount,
            image: image
        )
    }
}
