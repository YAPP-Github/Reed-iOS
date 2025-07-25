// Copyright © 2025 Booket. All rights reserved

import UIKit
import SnapKit

final class BKChipDemoViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var readingStatusChips: [BKChip] = []
    private var selectedReadingStatusIndex = 0
    
    private var genreChips: [BKChip] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupChips()
    }
    
    private func setupUI() {
        view.backgroundColor = .bkBaseColor(.primary)
        title = "BKChip Demo"
        
        setupScrollView()
        setupContent()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
    }
    
    private func setupContent() {
        let readingStatusLabel = createSectionLabel(text: "읽기 상태 (단일 선택)")
        let readingStatusStackView = createHorizontalStackView()
        
        let genreLabel = createSectionLabel(text: "장르 (다중 선택)")
        let genreStackView = createHorizontalStackView()
        
        let selectionInfoLabel = BKLabel(
            text: "선택된 항목들이 여기에 표시됩니다",
            fontStyle: .body2(weight: .regular),
            alignment: .left
        )
        selectionInfoLabel.setColor(color: .bkContentColor(.secondary))
        selectionInfoLabel.numberOfLines = 0
        
        contentView.addSubviews(
            readingStatusLabel,
            readingStatusStackView,
            genreLabel,
            genreStackView,
            selectionInfoLabel
        )
        
        // 레이아웃 설정
        readingStatusLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(BKSpacing.spacing4)
            $0.horizontalEdges.equalToSuperview().inset(BKSpacing.spacing3)
        }
        
        readingStatusStackView.snp.makeConstraints {
            $0.top.equalTo(readingStatusLabel.snp.bottom).offset(BKSpacing.spacing2)
            $0.horizontalEdges.equalToSuperview().inset(BKSpacing.spacing3)
        }
        
        genreLabel.snp.makeConstraints {
            $0.top.equalTo(readingStatusStackView.snp.bottom).offset(BKSpacing.spacing5)
            $0.horizontalEdges.equalToSuperview().inset(BKSpacing.spacing3)
        }
        
        genreStackView.snp.makeConstraints {
            $0.top.equalTo(genreLabel.snp.bottom).offset(BKSpacing.spacing2)
            $0.horizontalEdges.equalToSuperview().inset(BKSpacing.spacing3)
        }
        
        selectionInfoLabel.snp.makeConstraints {
            $0.top.equalTo(genreStackView.snp.bottom).offset(BKSpacing.spacing5)
            $0.horizontalEdges.equalToSuperview().inset(BKSpacing.spacing3)
            $0.bottom.lessThanOrEqualToSuperview().offset(-BKSpacing.spacing4)
        }
        
        // 칩들을 스택뷰에 추가하기 위해 저장
        self.setupReadingStatusChips(in: readingStatusStackView)
        self.setupGenreChips(in: genreStackView)
        self.setupSelectionInfo(label: selectionInfoLabel)
    }
    
    private func createSectionLabel(text: String) -> BKLabel {
        let label = BKLabel(
            text: text,
            fontStyle: .headline2(weight: .semiBold),
            alignment: .left
        )
        label.setColor(color: .bkContentColor(.primary))
        return label
    }
    
    private func createHorizontalStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = BKSpacing.spacing2
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }
    
    private func setupChips() {
        // 읽기 상태 칩 데이터
        let readingStatusData = [
            (title: "전체", count: 0),
            (title: "읽기 전", count: 0),
            (title: "읽는 중", count: 0),
            (title: "완독", count: 0)
        ]
        
        // 장르 칩 데이터
        let genreData = [
            (title: "소설", count: 12),
            (title: "에세이", count: 8),
            (title: "자기계발", count: 15),
            (title: "경제", count: 6)
        ]
        
        // 읽기 상태 칩 생성
        readingStatusChips = readingStatusData.enumerated().map { index, data in
            BKChip(title: data.title, count: data.count) { [weak self] in
                self?.handleReadingStatusSelection(at: index)
            }
        }
        
        // 장르 칩 생성
        genreChips = genreData.map { data in
            BKChip(title: data.title, count: data.count) { [weak self] in
                self?.updateSelectionInfo()
            }
        }
        
        // 기본 선택 설정
        readingStatusChips[0].isSelected = true
    }
    
    private func setupReadingStatusChips(in stackView: UIStackView) {
        readingStatusChips.forEach { chip in
            stackView.addArrangedSubview(chip)
        }
    }
    
    private func setupGenreChips(in stackView: UIStackView) {
        genreChips.forEach { chip in
            stackView.addArrangedSubview(chip)
        }
    }
    
    private func setupSelectionInfo(label: BKLabel) {
        updateSelectionInfo(label: label)
    }
    
    private func handleReadingStatusSelection(at index: Int) {
        // 기존 선택 해제
        readingStatusChips[selectedReadingStatusIndex].isSelected = false
        
        // 새로운 선택 설정
        selectedReadingStatusIndex = index
        readingStatusChips[index].isSelected = true
        
        updateSelectionInfo()
    }
    
    private func updateSelectionInfo(label: BKLabel? = nil) {
        let selectedReadingStatus = readingStatusChips[selectedReadingStatusIndex].title
        let selectedGenres = genreChips.compactMap { chip in
            chip.isSelected ? chip.title : nil
        }
        
        var infoText = "📚 읽기 상태: \(selectedReadingStatus)\n"
        
        if selectedGenres.isEmpty {
            infoText += "🏷️ 선택된 장르: 없음"
        } else {
            infoText += "🏷️ 선택된 장르: \(selectedGenres.joined(separator: ", "))"
        }
        
        // label이 있으면 해당 라벨 업데이트, 없으면 현재 화면의 라벨 찾아서 업데이트
        if let label = label {
            label.setText(text: infoText)
        } else {
            // contentView에서 BKLabel 찾아서 업데이트
            contentView.subviews.compactMap { $0 as? BKLabel }.last?.setText(text: infoText)
        }
        
        print("선택 상태 변경됨 - \(infoText.replacingOccurrences(of: "\n", with: " | "))")
    }
}
