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
        
        resultView?.removeFromSuperview()
        resultView = nil
        
        isUserInteractionEnabled = true
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func configure(
        title: String,
        description: BookDescription,
        image: URL?,
        canSelect: Bool = true,
        recordCount: Int? = nil
    ) {
        let style: BKBookSummaryViewStyle = {
            if recordCount != nil {
                return .record
            } else if canSelect {
                return .regular
            } else {
                return .alreadyEnroll
            }
        }()
        
        let view = BKBookSummaryView(style: style)
        contentView.addSubview(view)
        view.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(dividerView.snp.top)
        }
        self.resultView = view
        
        isUserInteractionEnabled = canSelect
        
        resultView?.configure(
            title: title,
            author: description.author,
            publisher: description.publisher,
            recordCount: recordCount,
            image: image
        )
    }
}
