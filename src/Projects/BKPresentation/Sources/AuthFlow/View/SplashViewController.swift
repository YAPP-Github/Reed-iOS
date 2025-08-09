// Copyright © 2025 Booket. All rights reserved

import BKDesign
import BKDomain
import Combine
import SnapKit
import UIKit

public protocol SplashViewControllerDelegate: AnyObject {
    func splashDidComplete()
}

public final class SplashViewController: UIViewController {
    private let splashView = SplashView()
    private var cancellables = Set<AnyCancellable>()
    
    public weak var delegate: SplashViewControllerDelegate?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(splashView)
        view.backgroundColor = .bkContentColor(.brand)
        
        splashView.snp.makeConstraints {
            $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        splashView.setupView()
        splashView.setLayout()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.delegate?.splashDidComplete()
        }
    }
}
