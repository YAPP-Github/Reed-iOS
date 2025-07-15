// Copyright © 2025 Booket. All rights reserved

import UIKit

///
class BaseViewController<T: BaseView>: UIViewController, BKNavigationBarStylable {
    // MARK: - Properties
    let contentView: T
    
    open var bkNavigationBarStyle: UINavigationController.BKNavigationBarStyle {
        fatalError("Subclasses must override bkNavigationBarStyle")
    }

    open var bkNavigationTitle: String {
        fatalError("Subclasses must override bkNavigationTitle")
    }
    
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
            contentView.backgroundColor = .bkBaseColor(.primary)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = self as? BKNavigationBarStylable {
            navigationController?.applyStyleIfNeeded(for: self)
        }
    }
    
    // MARK: - Common Methods
    func setupView() {}
    func configure() {}
    func setupLayout() {}
    func bindAction() {}
    func bindState() {}
}
