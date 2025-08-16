// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import Combine
import SnapKit
import UIKit
import VisionKit

final class OCRScannerViewController: UIViewController {
    
    enum LayoutGuide {
        static let buttonRadius: CGFloat = 36
        static let closeButtonTopOffset: CGFloat = 18
        static let closeButtonTrailingInset: CGFloat = 20
        static let closeButtonSize: CGFloat = 24
        static let captureButtonBottomInset: CGFloat = 16
        static let captureButtonSize: CGFloat = 72
        static let errorLabelBottomOffset: CGFloat = -16
        
        static let topDimHeight: CGFloat = 176
        static let bottomDimHeight: CGFloat = 138
    }
    
    enum LabelString {
        static let guideText = "수집할 문장이 화면에 모두 담기도록\n조정 후 하단 캡쳐 버튼을 눌러주세요"
        static let errorText = "문장을 인식하지 못했어요\n다시 한 번 촬영해주세요"
        static let dialogTitle = "문장을 인식하지 못했어요"
        static let dialogSubTitle = "직접 문장을 입력하시겠어요?"
        static let leftOption = "다시 촬영하기"
        static let rightOption = "직접 입력하기"
    }
    
    // MARK: - Properties
    weak var coordinator: NoteCoordinator?
    private let viewModel: OCRScannerViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var scannerViewController: DataScannerViewController?
    private var topDimView = UIView()
    private var bottomDimView = UIView()
    
    private let guideLabel = BKLabel(
        text: LabelString.guideText,
        fontStyle: .headline2(weight: .medium),
        color: .bkContentColor(.inverse),
        alignment: .center
    )
    
    private var errorBackView = UIView()
    private let errorLabel = BKLabel(
        text: LabelString.errorText,
        fontStyle: .label1(weight: .medium),
        color: .bkContentColor(.inverse),
        alignment: .center
    )
    
    private let captureButton = UIButton()
    private let closeButton = UIButton()
    
    // MARK: - Lifecycle
    init(viewModel: OCRScannerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScanner()
        bindViewModel()
        viewModel.send(.viewDidLoad)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.send(.startScanning)
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.send(.stopScanning)
        stopScanning()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        guideLabel.numberOfLines = 2
        errorLabel.numberOfLines = 2
        errorBackView.isHidden = true
        
        closeButton.setImage(BKImage.Icon.x, for: .normal)
        closeButton.tintColor = .bkContentColor(.inverse)
        closeButton.addTarget(
            self,
            action: #selector(closeButtonTapped),
            for: .touchUpInside
        )
        
        captureButton.backgroundColor = .bkBackgroundColor(.primary)
        captureButton.layer.cornerRadius = LayoutGuide.buttonRadius
        let resizedImage = BKImage.Icon.maximize.resizedAsTemplate(to: CGSize(width: 32, height: 32))
        captureButton.setImage(resizedImage, for: .normal)
        captureButton.tintColor = .bkBaseColor(.primary)
        captureButton.addTarget(
            self,
            action: #selector(captureButtonTapped),
            for: .touchUpInside
        )
        
        errorBackView.backgroundColor = UIColor(hex: "0A0A0A").withAlphaComponent(0.8)
        errorBackView.clipsToBounds = true
        errorBackView.layer.cornerRadius = BKRadius.small
        
        topDimView.backgroundColor = UIColor(hex: "0A0A0A").withAlphaComponent(0.5)
        bottomDimView.backgroundColor = UIColor(hex: "0A0A0A").withAlphaComponent(0.5)
        
        errorBackView.addSubview(errorLabel)
        view.addSubviews(topDimView, bottomDimView, guideLabel, closeButton, captureButton,  errorBackView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        topDimView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(LayoutGuide.topDimHeight)
        }
        
        bottomDimView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(LayoutGuide.bottomDimHeight)
        }
        
        guideLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(topDimView.snp.bottom).offset(-24)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(LayoutGuide.closeButtonTopOffset)
            $0.trailing.equalToSuperview().inset(LayoutGuide.closeButtonTrailingInset)
            $0.size.equalTo(LayoutGuide.closeButtonSize)
        }
        
        captureButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(LayoutGuide.captureButtonBottomInset)
            $0.size.equalTo(LayoutGuide.captureButtonSize)
        }
        
        errorLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        
        errorBackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(bottomDimView.snp.top).offset(-16)
        }

    }
    
    private func setupScanner() {
        guard DataScannerViewController.isSupported else {
            // "이 기기에서는 텍스트 스캔을 지원하지 않습니다."
            return
        }
        
        // OCR 인식 가능한 언어
        let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [
            .text(languages: ["ko-KR", "en-US"])
        ]
        
        let scanner = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: false,
            isHighlightingEnabled: false
        )
        
        scanner.delegate = self

        addChild(scanner)
        view.insertSubview(scanner.view, at: 0)
        scanner.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scanner.didMove(toParent: self)
        
        scannerViewController = scanner
    }
    
    private func bindViewModel() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
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
    
    private func render(_ state: OCRScannerViewModel.State) {
        if state.shouldShowDialog {
            showFailureDialog()
            viewModel.send(.dialogDismissed)
        } else if state.shouldShowAlert {
            errorBackView.isHidden = false
            viewModel.send(.alertDismissed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.errorBackView.isHidden = true
            }
        }
    }
    
    // MARK: - Scanner Control
    private func startScanning() {
        Task {
            do {
                try scannerViewController?.startScanning()
            } catch {
                debugPulse(error)
            }
        }
    }
    
    private func stopScanning() {
        scannerViewController?.stopScanning()
    }
}

extension OCRScannerViewController {
    @objc
    private func closeButtonTapped() {
        viewModel.send(.closeButtonTapped)
    }
    
    @objc
    private func captureButtonTapped() {
        viewModel.send(.captureButtonTapped)
    }
    
    private func showFailureDialog() {
        let dialog = BKDialog(
            title: LabelString.dialogTitle,
            subtitle: LabelString.dialogSubTitle,
            config: .init(
                leftButtonTitle: LabelString.leftOption,
                leftButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                    self?.viewModel.send(.resetFailureCount)
                },
                rightButtonTitle: LabelString.rightOption,
                rightButtonAction: { [weak self] in
                    self?.dismiss(animated: true)
                    self?.viewModel.send(.closeButtonTapped)
                }
            )
        )
        
        let dialogViewController = BKDialogViewController(dialog: dialog)
        present(dialogViewController, animated: true)
    }
}

// MARK: - DataScannerViewControllerDelegate
extension OCRScannerViewController: DataScannerViewControllerDelegate {
    func dataScanner(
        _ dataScanner: DataScannerViewController,
        didAdd addedItems: [RecognizedItem],
        allItems: [RecognizedItem]
    ) {
        viewModel.send(.itemsAdded(addedItems, allItems: allItems))
    }
    
    func dataScanner(
        _ dataScanner: DataScannerViewController,
        didUpdate updatedItems: [RecognizedItem],
        allItems: [RecognizedItem]
    ) {
        viewModel.send(.itemsUpdated(updatedItems, allItems: allItems))
    }
    
    func dataScanner(
        _ dataScanner: DataScannerViewController,
        didRemove removedItems: [RecognizedItem],
        allItems: [RecognizedItem]
    ) {
        viewModel.send(.itemsRemoved(removedItems, allItems: allItems))
    }
}

extension UIImage {
    func resizedAsTemplate(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        
        return resizedImage.withRenderingMode(.alwaysTemplate)
    }
}
