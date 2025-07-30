// Copyright © 2025 Booket. All rights reserved

import BKDesign
import Combine
import SnapKit
import UIKit
import VisionKit

enum ScannerOverlayViewEvent {
    case captureButtonTap
    case closeButtonTap
}

final class ScannerOverlayView: UIView {
    let eventPublisher = PassthroughSubject<ScannerOverlayViewEvent, Never>()
    
    // MARK: - UI Components
    private let overlayView = UIView()
    private let innerMaskView = UIView() // 마스킹 영역 계산용
    
    private let guideLabel = BKLabel(
        text: "수집할 문장을 중앙에 맞춰 \n캡처 버튼을 눌러주세요",
        fontStyle: .headline2(weight: .medium),
        color: .bkContentColor(.inverse),
        alignment: .center
    )
//    private let errorMessageLabel = UILabel()
    
    let captureButton = UIButton()
    let closeButton = UIButton()
    
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        applyMasks()
        drawCorners()
    }
    
    private func setupUI() {
        backgroundColor = .black
        
        overlayView.backgroundColor = UIColor(hex: "262626").withAlphaComponent(0.6)
        
        // 가이드 라벨
        guideLabel.numberOfLines = 2
        
        // 닫기 버튼
        closeButton.setImage(BKImage.Icon.x, for: .normal)
        closeButton.tintColor = .bkContentColor(.inverse)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // 캡처 버튼
        captureButton.backgroundColor = .bkBackgroundColor(.primary)
        captureButton.layer.cornerRadius = 36
        captureButton.setImage(BKImage.Icon.maximize, for: .normal)
        captureButton.tintColor = .bkBaseColor(.primary)
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        
        innerMaskView.isHidden = true
        
        // errorMessageLabel.isHidden = true
        
        addSubviews(overlayView, innerMaskView, guideLabel, closeButton, captureButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        overlayView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo()
        }
        
        innerMaskView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().inset(20)
            $0.height.equalToSuperview().inset(20)
        }
        
        guideLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(overlayView.snp.top).offset(-40)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(44)
        }
        
        captureButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(50)
            $0.size.equalTo(70)
        }
    }
    
    private func drawCorners() {
        innerMaskView.layer.sublayers?.removeAll { $0.name == "cornerLayer" }

        let cornerLength: CGFloat = 26.0
        let lineWidth: CGFloat = 4.0
        
        let path = UIBezierPath()
        // Top-Left
        path.move(to: CGPoint(x: 20, y: cornerLength))
        path.addLine(to: CGPoint(x: 20, y: 20))
        path.addLine(to: CGPoint(x: cornerLength, y: 20))
        // Top-Right
        path.move(to: CGPoint(x: innerMaskView.bounds.width - cornerLength, y: 20))
        path.addLine(to: CGPoint(x: innerMaskView.bounds.width, y: 20))
        path.addLine(to: CGPoint(x: innerMaskView.bounds.width, y: cornerLength))
        // Bottom-Left
        path.move(to: CGPoint(x: 20, y: innerMaskView.bounds.height - cornerLength))
        path.addLine(to: CGPoint(x: 20, y: innerMaskView.bounds.height))
        path.addLine(to: CGPoint(x: cornerLength, y: innerMaskView.bounds.height))
        // Bottom-Right
        path.move(to: CGPoint(x: innerMaskView.bounds.width - cornerLength, y: innerMaskView.bounds.height))
        path.addLine(to: CGPoint(x: innerMaskView.bounds.width, y: innerMaskView.bounds.height))
        path.addLine(to: CGPoint(x: innerMaskView.bounds.width, y: innerMaskView.bounds.height - cornerLength))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        shapeLayer.strokeColor = UIColor.bkBackgroundColor(.primary).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.name = "cornerLayer"
        
        scanAreaView.layer.addSublayer(shapeLayer)
    }
    
    
    func setupMasks() {
        // Part 1: overlayView에서 scanAreaView 영역 뚫기
        let overlayMaskLayer = CAShapeLayer()
        
        // 1. 전체 영역을 채우는 경로 생성
        let overlayPath = UIBezierPath(rect: overlayView.bounds)
        // 2. 구멍으로 사용할 scanAreaView의 프레임 경로 생성
        let scanAreaPath = UIBezierPath(rect: self.scanAreaView.frame)
        
        // 3. 두 경로를 합치고 evenOdd 룰 적용
        overlayPath.append(scanAreaPath)
        overlayPath.usesEvenOddFillRule = true
        
        overlayMaskLayer.path = overlayPath.cgPath
        overlayView.layer.mask = overlayMaskLayer
        

        // Part 2: scanAreaView에서 innerMaskView 영역 뚫기
        let scanAreaMaskLayer = CAShapeLayer()
        
        // 1. scanAreaView 전체 영역을 채우는 경로 생성
        let holePath = UIBezierPath(rect: scanAreaView.bounds)
        
        // 2. 구멍으로 사용할 innerMaskView의 프레임을 scanAreaView의 좌표계로 변환
        let innerMaskFrame = scanAreaView.convert(innerMaskView.frame, from: self)
        let innerMaskPath = UIBezierPath(rect: innerMaskFrame)
        
        // 3. 두 경로를 합치고 evenOdd 룰 적용
        holePath.append(innerMaskPath)
        holePath.usesEvenOddFillRule = true
        
        scanAreaMaskLayer.path = holePath.cgPath
        scanAreaView.layer.mask = scanAreaMaskLayer
    }
    
//    func setErrorMessage(_ message: String?) {
//        if let message = message, !message.isEmpty {
//            errorMessageLabel.text = message
//            errorMessageLabel.isHidden = false
//        } else {
//            errorMessageLabel.isHidden = true
//        }
//    }
    
    // MARK: - Actions
    @objc private func captureButtonTapped() {
        eventPublisher.send(.captureButtonTap)
    }

    @objc private func closeButtonTapped() {
        eventPublisher.send(.closeButtonTap)
    }
}
