// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import Combine
import SnapKit
import UIKit

final class RecognizedTextViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: RecognizedTextViewModel
    private let recognizedTexts: [String]
    private var cancellables = Set<AnyCancellable>()
    
    // UI Components
    private let titleLabel = BKLabel(
        text: "기록할 문장 선택",
        fontStyle: .headline2(weight: .semiBold),
        color: .bkContentColor(.primary),
        alignment: .center
    )
    
    private let closeButton = UIButton()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    private lazy var dataSource = createDataSource()
    
    private let buttonGroup = BKButtonGroup.twoButtonGroup(
        leftTitle: "다시 촬영하기",
        rightTitle: "선택 완료"
    )
    
    // Callbacks
    var onConfirm: ((String) -> Void)?
    var onRetake: (() -> Void)?
    
    // MARK: - Lifecycle
    init(recognizedTexts: [String], viewModel: RecognizedTextViewModel) {
        self.recognizedTexts = recognizedTexts
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtonActions()
        bindViewModel()
        
        viewModel.send(.viewDidLoad(recognizedTexts))
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .bkBaseColor(.primary)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = false
        collectionView.bounces = false
        setupTitleAndCloseButton()
        setupCollectionView()
        setupConstraints()
    }
    
    private func setupTitleAndCloseButton() {
        closeButton.setImage(BKImage.Icon.x, for: .normal)
        closeButton.tintColor = .bkContentColor(.primary)
        closeButton.addTarget(
            self,
            action: #selector(closeButtonTapped),
            for: .touchUpInside
        )
        
        view.addSubviews(titleLabel, closeButton)
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        
        view.addSubviews(collectionView, buttonGroup)
    }
    
    private func setupButtonActions() {
        buttonGroup.bindTwoButtonsAction(
            leftAction: { [weak self] in
                self?.viewModel.send(.retakeButtonTapped)
            },
            rightAction: { [weak self] in
                self?.viewModel.send(.confirmButtonTapped)
            }
        )
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            $0.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(24)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(buttonGroup.snp.top)
        }
        
        buttonGroup.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    // MARK: - Collection View Layout & DataSource
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(72)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(72)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Int, RecognizedTextViewModel.SentenceItem> {
        let cellRegistration = UICollectionView.CellRegistration<SentenceListCell, RecognizedTextViewModel.SentenceItem> { cell, indexPath, item in
            cell.configure(with: item)
        }
        
        return UICollectionViewDiffableDataSource<Int, RecognizedTextViewModel.SentenceItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    private func updateDataSource(with sentences: [RecognizedTextViewModel.SentenceItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, RecognizedTextViewModel.SentenceItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(sentences)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func bindViewModel() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
        
        viewModel.sideEffectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sideEffect in
                self?.handleSideEffect(sideEffect)
            }
            .store(in: &cancellables)
        
        viewModel.statePublisher
            .map { $0.isLoading }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
            .store(in: &cancellables)
    }
    
    private func render(_ state: RecognizedTextViewModel.State) {
        updateDataSource(with: state.sentences)
        
        // 확인 버튼 상태 업데이트
        buttonGroup.setPrimaryButtonState(state.isConfirmButtonEnabled)
        
        // 에러 메시지 표시
        if let errorMessage = state.errorMessage {
            showAlert(message: errorMessage)
        }
    }
    
    private func handleSideEffect(_ sideEffect: RecognizedTextViewModel.SideEffect) {
        switch sideEffect {
        case .confirmWithSelectedText(let selectedText):
            debugPulse(selectedText)
            onConfirm?(selectedText)
            
        case .dismissToRetake:
            onRetake?()
        }
    }
    
    // MARK: - Actions
    @objc
    private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Helpers
    // TODO : BK다이얼로그로 교체하기 @dyk429
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension RecognizedTextViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        viewModel.send(.sentenceToggled(index: indexPath.item))
    }
    
}
