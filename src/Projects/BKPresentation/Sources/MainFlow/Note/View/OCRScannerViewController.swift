// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit
import VisionKit

final class OCRScannerViewController: UIViewController {
    
    // MARK: - Properties
    weak var coordinator: NoteCoordinator?
    private let viewModel: OCRScannerViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var scannerViewController: DataScannerViewController?
    private let scanAreaView = UIView()
    private let overlayView = UIView()
    private let scanOverlayView = UIImageView(image: UIImage(named: "dim"))
    
    private let guideLabel = BKLabel(
        text: "수집할 문장을 중앙에 맞춰 \n캡처 버튼을 눌러주세요",
        fontStyle: .headline2(weight: .medium),
        color: .bkContentColor(.inverse),
        alignment: .center
    )
    
    private let captureButton = UIButton()
    private let closeButton = UIButton()
    
    // 스캔 영역 비율 (화면 대비)
    private let scanAreaRatio: CGFloat = 0.7
    
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
        
        // 가이드 라벨 추가 설정
        guideLabel.numberOfLines = 2
        
        // 닫기 버튼
        closeButton.setImage(BKImage.Icon.x, for: .normal)
        closeButton.tintColor = .bkContentColor(.inverse)
        closeButton.addTarget(
            self,
            action: #selector(closeButtonTapped),
            for: .touchUpInside
        )
        
        // 캡처 버튼
        captureButton.backgroundColor = .bkBackgroundColor(.primary)
        captureButton.layer.cornerRadius = 36
        captureButton.setImage(BKImage.Icon.maximize, for: .normal)
        captureButton.tintColor = .bkBaseColor(.primary)
        captureButton.addTarget(
            self,
            action: #selector(captureButtonTapped),
            for: .touchUpInside
        )
        
        // 스캔 영역 뷰 (초록색 테두리)
//        scanAreaView.layer.borderColor = UIColor.bkBackgroundColor(.primary).cgColor
//        scanAreaView.layer.borderWidth = 1
//        scanAreaView.layer.cornerRadius = 12
        scanAreaView.backgroundColor = .clear
        scanAreaView.isUserInteractionEnabled = false
        
        // 오버레이 설정 (스캔 영역 외부를 어둡게)
        overlayView.backgroundColor = .clear
        overlayView.isUserInteractionEnabled = false
        
        view.addSubviews(overlayView, scanAreaView, scanOverlayView, guideLabel, closeButton, captureButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        scanAreaView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(scanAreaView.snp.width)
        }
        
        scanOverlayView.snp.makeConstraints {
            $0.leading.trailing.equalTo(scanAreaView)
            $0.top.bottom.equalTo(scanAreaView)
        }
        
        guideLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(scanAreaView.snp.top).offset(-40)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(44)
        }
        
        captureButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
            $0.size.equalTo(72)
        }
    }
    
    private func setupScanner() {
        guard DataScannerViewController.isSupported else {
            showAlert(message: "이 기기에서는 텍스트 스캔을 지원하지 않습니다.")
            return
        }
        
        // 한국어와 영어 지원
        let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [
            .text(languages: ["ko-KR", "en-US"])
        ]
        
        let scanner = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
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
        DispatchQueue.main.async { [weak self] in
            self?.setupOverlayMask()
        }
    }
    
    private func setupOverlayMask() {
        let path = UIBezierPath(rect: overlayView.bounds)
        
        // 스캔 영역에 해당하는 부분을 뚫음
        let scanAreaFrame = scanAreaView.frame
        let scanPath = UIBezierPath(roundedRect: scanAreaFrame, cornerRadius: 0)
        path.append(scanPath)
        path.usesEvenOddFillRule = true
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.black.cgColor
        
        overlayView.layer.addSublayer(maskLayer)
    }
    
    private func bindViewModel() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }
    
    private func render(_ state: OCRScannerViewModel.State) {
        // 알림 표시
        if state.shouldShowAlert {
            showAlert(message: state.alertMessage)
            viewModel.send(.alertDismissed)
        }
        
        // 에러 메시지 표시
        if let errorMessage = state.errorMessage {
            showAlert(message: errorMessage)
        }
    }
    
    // MARK: - Scanner Control
    private func startScanning() {
        Task {
            try? await scannerViewController?.startScanning()
        }
    }
    
    private func stopScanning() {
        scannerViewController?.stopScanning()
    }
    
    // MARK: - Actions
    @objc
    private func closeButtonTapped() {
        viewModel.send(.closeButtonTapped)
    }
    
    @objc
    private func captureButtonTapped() {
        let scanAreaFrame = scanAreaView.frame
        viewModel.send(.captureButtonTapped(scanAreaFrame: scanAreaFrame))
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - DataScannerViewControllerDelegate
extension OCRScannerViewController: DataScannerViewControllerDelegate {
    func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        viewModel.send(.itemsAdded(addedItems, allItems: allItems))
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        viewModel.send(.itemsUpdated(updatedItems, allItems: allItems))
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        viewModel.send(.itemsRemoved(removedItems, allItems: allItems))
    }
    
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        // 현재는 탭 기능을 사용하지 않으므로 빈 상태로 유지
        // 필요시 viewModel에 액션 추가 가능
    }
}
