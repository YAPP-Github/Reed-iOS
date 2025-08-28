// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKDesign
import Combine
import SnapKit
import UIKit
import Vision
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
    
    private lazy var ciContext = CIContext(options: [.useSoftwareRenderer: false])
    
    private struct Preproc {
        static let exposureEV: CGFloat = 0.5
        static let unsharpRadius: CGFloat = 1.5
        static let unsharpIntensity: CGFloat = 0.4
        static let shadowLift: CGFloat = 0.25
        static let minTextHeight: CGFloat = 0.012   // 0.008~0.015 범위에서 튜닝
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateRegionOfInterest()
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
                return
        }
        
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
            isHighlightingEnabled: true
        )
        
        scanner.delegate = self

        addChild(scanner)
        view.insertSubview(scanner.view, at: 0)
        scanner.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        scanner.didMove(toParent: self)
        
        scannerViewController = scanner
        updateRegionOfInterest()
    }
    
    private func updateRegionOfInterest() {
        guard let scanner = scannerViewController else { return }

        view.layoutIfNeeded()

        let parentBounds = view.bounds
        let regionOfInterest = CGRect(
            x: 0,
            y: LayoutGuide.topDimHeight,
            width: parentBounds.width,
            height: parentBounds.height - LayoutGuide.topDimHeight - LayoutGuide.bottomDimHeight
        )

        let convertedRegion = scanner.view.convert(regionOfInterest, from: view)
        scanner.regionOfInterest = convertedRegion
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
                // Silently handle scanning errors
            }
        }
    }
    
    private func stopScanning() {
        scannerViewController?.stopScanning()
    }
    
    // MARK: - Vision Processing
    private func captureCurrentFrame() {
        guard let scanner = scannerViewController else { return }
        
        viewModel.send(.captureButtonTapped)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.captureFrameAndProcessWithVision(from: scanner)
        }
    }
    
    private func captureFrameAndProcessWithVision(from scanner: DataScannerViewController) {
        guard let v = scanner.view else { return }

        let fmt = UIGraphicsImageRendererFormat.default()
        fmt.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(bounds: v.bounds, format: fmt)
        let fullUIImage = renderer.image { _ in
            v.drawHierarchy(in: v.bounds, afterScreenUpdates: false)
        }
        guard let fullCG = fullUIImage.cgImage else {
            processImageWithVision(fullUIImage)
            return
        }

        guard let roi = scanner.regionOfInterest else { return }
        let scale = fullUIImage.scale
        let cropRectPx = CGRect(
            x: roi.origin.x * scale,
            y: roi.origin.y * scale,
            width: roi.size.width * scale,
            height: roi.size.height * scale
        ).integral

        let croppedImage = fullCG.cropping(to: cropRectPx) ?? fullCG

        let preprocessedImage = preprocessForOCR(croppedImage) ?? croppedImage
        processCGImageWithVision(preprocessedImage)
    }
    
    private func preprocessForOCR(_ cgImage: CGImage) -> CGImage? {
        var ciImage = CIImage(cgImage: cgImage)

        ciImage = ciImage.applyingFilter("CIPhotoEffectMono")
        ciImage = ciImage.applyingFilter("CIExposureAdjust", parameters: [kCIInputEVKey: Preproc.exposureEV])
        ciImage = ciImage.applyingFilter("CIUnsharpMask", parameters: [
            kCIInputRadiusKey: Preproc.unsharpRadius,
            kCIInputIntensityKey: Preproc.unsharpIntensity
        ])
        ciImage = ciImage.applyingFilter("CIHighlightShadowAdjust", parameters: [
            "inputShadowAmount": Preproc.shadowLift
        ])

        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }
    
    private func processCGImageWithVision(_ cgImage: CGImage) {
        let request = VNRecognizeTextRequest { [weak self] req, err in
            DispatchQueue.main.async {
                self?.handleVisionResult(request: req, error: err)
            }
        }
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.usesLanguageCorrection = true
        request.minimumTextHeight = Float(Preproc.minTextHeight)

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.handleVisionResult(request: nil, error: error)
                }
            }
        }
    }
    
    private func processImageWithVision(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.handleVisionResult(request: request, error: error)
            }
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.handleVisionResult(request: nil, error: error)
                }
            }
        }
    }
    
    private func handleVisionResult(request: VNRequest?, error: Error?) {
        if let error = error {
            viewModel.send(.captureButtonTapped)
            return
        }
        
        guard let observations = request?.results as? [VNRecognizedTextObservation] else {
            viewModel.send(.captureButtonTapped)
            return
        }
        
        let recognizedTexts = extractTextFromVisionObservations(observations)
        
        if recognizedTexts.isEmpty {
            viewModel.send(.captureButtonTapped)
        } else {
            viewModel.send(.visionTextCaptured(recognizedTexts))
        }
    }
    
    private func extractTextFromVisionObservations(_ observations: [VNRecognizedTextObservation]) -> [String] {
        var texts: [String] = []
        
        let sortedObservations = observations.sorted { obs1, obs2 in
            let box1 = obs1.boundingBox
            let box2 = obs2.boundingBox
            
            if abs(box1.origin.y - box2.origin.y) < 0.05 {
                return box1.origin.x < box2.origin.x
            }
            return box1.origin.y > box2.origin.y
        }
        
        for observation in sortedObservations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            let text = topCandidate.string.trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                texts.append(text)
            }
        }
        
        return texts
    }
}

extension OCRScannerViewController {
    @objc
    private func closeButtonTapped() {
        viewModel.send(.closeButtonTapped)
    }
    
    @objc
    private func captureButtonTapped() {
        scannerViewController?.stopScanning()
        captureCurrentFrame()
        try? scannerViewController?.startScanning()
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
