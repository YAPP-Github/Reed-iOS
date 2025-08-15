// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKCore
import Combine
import SnapKit
import UIKit
import VisionKit

final class OCRScannerViewController: UIViewController {
    
    enum LayoutGuide {
        static let buttonRadius: CGFloat = 36
        static let scanAreaHeight: CGFloat = 200
        static let guideLabelBottomOffset: CGFloat = -48
        static let closeButtonTopOffset: CGFloat = 18
        static let closeButtonTrailingInset: CGFloat = 20
        static let closeButtonSize: CGFloat = 24
        static let captureButtonBottomInset: CGFloat = 16
        static let captureButtonSize: CGFloat = 72
        static let errorLabelBottomOffset: CGFloat = -16
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
//    private let scanAreaView = UIView()
//    private let overlayView = UIView()
//    private let scanOverlayView = UIImageView(image: UIImage(named: "dim"))
    
    private let guideLabel = BKLabel(
        text: LabelString.guideText,
        fontStyle: .headline2(weight: .medium),
        color: .bkContentColor(.inverse),
        alignment: .center
    )
    
    private let errorLabel = BKLabel(
        text: LabelString.errorText,
        fontStyle: .label2(weight: .semiBold),
        color: .bkContentColor(.error),
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
        guideLabel.backgroundColor = .black
        errorLabel.numberOfLines = 2
        errorLabel.isHidden = true
        
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
//        
//        scanAreaView.backgroundColor = .clear
//        scanAreaView.isUserInteractionEnabled = false
        
//        overlayView.backgroundColor = .clear
//        overlayView.isUserInteractionEnabled = false
        
//        view.addSubviews(overlayView, scanAreaView, scanOverlayView, guideLabel, closeButton, captureButton, errorLabel)
        view.addSubviews(guideLabel, closeButton, captureButton, errorLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
//        overlayView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
        
//        scanAreaView.snp.makeConstraints {
//            $0.center.equalToSuperview()
//            $0.width.equalToSuperview()
//            $0.height.equalTo(LayoutGuide.scanAreaHeight)
//        }
//        
//        scanOverlayView.snp.makeConstraints {
//            $0.leading.trailing.equalTo(scanAreaView)
//            $0.top.bottom.equalTo(scanAreaView)
//        }
        
        guideLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(LayoutGuide.closeButtonTopOffset)
            
//            $0.bottom.equalTo(scanAreaView.snp.top).offset(LayoutGuide.guideLabelBottomOffset)
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
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(captureButton.snp.top).offset(LayoutGuide.errorLabelBottomOffset)
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
        
        // Scanner를 자식 뷰컨트롤러로 추가
        addChild(scanner)
        view.insertSubview(scanner.view, at: 0)
        scanner.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scanner.didMove(toParent: self)
        
        scannerViewController = scanner
        
        // 오버레이 마스크 설정
//        DispatchQueue.main.async { [weak self] in
//            self?.setupOverlayMask()
//        }
    }
    
//    private func setupOverlayMask() {
//        let path = UIBezierPath(rect: overlayView.bounds)
//        
//        // 스캔 영역에 해당하는 부분을 뚫음
//        let scanAreaFrame = scanAreaView.frame
//        let scanPath = UIBezierPath(roundedRect: scanAreaFrame, cornerRadius: 0)
//        path.append(scanPath)
//        path.usesEvenOddFillRule = true
//        
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = path.cgPath
//        maskLayer.fillRule = .evenOdd
//        maskLayer.fillColor = UIColor.black.cgColor
//        
//        overlayView.layer.addSublayer(maskLayer)
//    }
    
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
            errorLabel.isHidden = false
            viewModel.send(.alertDismissed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.errorLabel.isHidden = true
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
    
//    func dataScanner(
//        _ dataScanner: DataScannerViewController,
//        didUpdate updatedItems: [RecognizedItem],
//        allItems: [RecognizedItem]
//    ) {
//        viewModel.send(.itemsUpdated(updatedItems, allItems: allItems))
//    }
    
//    func dataScanner(
//        _ dataScanner: DataScannerViewController,
//        didRemove removedItems: [RecognizedItem],
//        allItems: [RecognizedItem]
//    ) {
//        viewModel.send(.itemsRemoved(removedItems, allItems: allItems))
//    }
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
