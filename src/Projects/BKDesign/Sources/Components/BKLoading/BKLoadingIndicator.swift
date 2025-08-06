// Copyright © 2025 Booket. All rights reserved

import UIKit
import SnapKit

public final class LoadingIndicator {
    
    private static let tag = 999999
    
    /// 로딩 인디케이터 보여주기
    public static func show() {
        DispatchQueue.main.async {
            guard let window = getKeyWindow() else { return }
            
            if window.viewWithTag(tag) != nil {
                return
            }
            
            let loadingIndicatorView = createLoadingView(frame: window.bounds)
            loadingIndicatorView.tag = tag
            
            window.addSubview(loadingIndicatorView)
            loadingIndicatorView.startAnimating()
        }
    }
    
    /// 로딩 인디케이터 숨기기
    public static func hide() {
        DispatchQueue.main.async {
            guard let window = getKeyWindow() else { return }
            
            window.subviews.filter({ $0.tag == tag }).forEach {
                $0.removeFromSuperview()
            }
        }
    }
    
    private static func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    private static func createLoadingView(frame: CGRect) -> UIActivityIndicatorView {
        let loadingIndicatorView = UIActivityIndicatorView(style: .large)
        loadingIndicatorView.frame = frame
        loadingIndicatorView.color = .bkContentColor(.brand)
        
        return loadingIndicatorView
    }
}

extension UIViewController {
    
    /// 로딩 시작
    public func showLoading() {
        LoadingIndicator.show()
    }
    
    /// 로딩 종료
    public func hideLoading() {
        LoadingIndicator.hide()
    }
}
