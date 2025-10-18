// Copyright © 2025 Booket. All rights reserved

import BKCore
import BKData
import BKDesign
import BKDomain
import BKNetwork
import BKPresentation
import BKStorage
import KakaoSDKAuth
#if DEBUG
import Pulse
import PulseUI
#endif
import SwiftUI
import UIKit

public final class DebugOptionViewController: UIViewController {

    private struct DebugSection {
        let title: String
        let options: [DebugOption]
    }

    private enum DebugOption: String, CaseIterable {
        case showNetworkLog = "네트워크 로그 확인"
        case resetOnboardingSeen = "온보딩 화면 보기"

        // 각 옵션에 따라 실행할 함수를 연결
        func performAction(on viewController: UIViewController) {
            guard let vc = viewController as? DebugOptionViewController else { return }
            switch self {
            case .showNetworkLog:
                vc.openPulseLog()
            case .resetOnboardingSeen:
                vc.resetOnboardingSeen()
            }
        }
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var sections: [DebugSection] = []
    
    @Autowired var markOnboardingSeenUseCase: MarkOnboardingSeenUseCase

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        setupTableView()
    }

    private func setupData() {
        self.sections = [
            DebugSection(title: "Log", options: [
                .showNetworkLog
            ]),
            DebugSection(title: "플래그 초기화", options: [
                .resetOnboardingSeen
            ])
        ]
    }
    
    // UI 설정은 동일
    private func setupUI() {
        self.title = "디버그 메뉴"
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // 테이블뷰 설정은 동일
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DebugCell")
    }

    // 각 셀 선택 시 호출될 함수들
    private func openPulseLog() {
        DispatchQueue.main.async { [weak self] in
            let viewController = MainViewController()
            self?.navigationController?.present(viewController, animated: true)
        }
    }
    
    private func resetOnboardingSeen() {
        markOnboardingSeenUseCase.reset()
        forceQuitApplication()
    }
    
    private func forceQuitApplication() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exit(0)
        }
    }
}

extension DebugOptionViewController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DebugCell", for: indexPath)
        let option = sections[indexPath.section].options[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = option.rawValue
        cell.contentConfiguration = content
        cell.accessoryType = .none
        
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedOption = sections[indexPath.section].options[indexPath.row]
        selectedOption.performAction(on: self)
    }
}
