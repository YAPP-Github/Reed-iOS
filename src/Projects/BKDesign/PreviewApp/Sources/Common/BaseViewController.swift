// Copyright © 2025 Booket. All rights reserved

import UIKit

class BaseViewController<T: BaseView>: UIViewController {
    // MARK: - Properties
    let contentView: T
    
    // MARK: - Initialize
    init() {
        self.contentView = T()
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func loadView() {
        if contentView.backgroundColor == nil {
            contentView.backgroundColor = .white
        }
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.configure()
        self.setupLayout()
        self.bindAction()
        self.bindState()
    }
    
    // MARK: - Common Methods
    func setupView() {}
    func configure() {}
    func setupLayout() {}
    func bindAction() {}
    func bindState() {}
}
