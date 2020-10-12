//
//  MenuViewController.swift
//
//  Created by Gabriele Mondada on 29.01.19.
//  Copyright © 2019 Gabriele Mondada. All rights reserved.
//

import Foundation
import UIKit

struct Action {
    let title: String
    let routine: () -> Void
}

class MenuViewController: UITableViewController {

    private let cellId = "Cell"
    private let switchCellId = "SwitchCell"
    private var actions = [Action]()

    init() {
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        actions = [
            Action(title: "Push") {
                [unowned self] in
                self.push()
            },
            Action(title: "Global Switch to Root Nav") {
                [unowned self] in
                self.globalFlipToRootNav()
            },
            Action(title: "Global Switch to Lonely Menu") {
                [unowned self] in
                self.globalFlipToLonelyMenu()
            },
            Action(title: "Global Switch to Root Nav Twice (not supported when flipping") {
                [unowned self] in
                self.globalFlipToRootNavTwice()
            },
        ]

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(SwitchCell.self, forCellReuseIdentifier: switchCellId)
    }

    override func viewWillAppear(_ animated: Bool) {
        print("Menu: \(title ?? "<no title"): viewWillAppear")
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        print("Menu: \(title ?? "<no title"): viewDidAppear")
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("Menu: \(title ?? "<no title"): viewWillDisappear")
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("Menu: \(title ?? "<no title"): viewDidDisappear")
        super.viewDidDisappear(animated)
    }

    // Actions

    func push() {
        let title = "Number \(navigationController?.viewControllers.count ?? 0 + 1)"
        let vc = MenuViewController()
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }

    private var rootSwitchViewController: VerbexSwitchViewController? {
        var parent: UIViewController = self
        while true {
            if let p = parent.parent {
                parent = p
            } else {
                break
            }
        }
        return parent as? VerbexSwitchViewController
    }

    func globalFlipToRoot() {
        let duration: TimeInterval = globalSettings.isSlow ? 5.0 : .nan
        rootSwitchViewController?.transitionDuration = duration
        let vc = RootViewController()
        rootSwitchViewController?.switchView(to: vc, animation: .flipFromLeft)
    }

    func globalFlipToRootNav() {
        let duration: TimeInterval = globalSettings.isSlow ? 5.0 : .nan
        rootSwitchViewController?.transitionDuration = duration
        let vc = RootNavViewController()
        rootSwitchViewController?.switchView(to: vc, animation: .flipFromLeft)
    }

    func globalFlipToLonelyMenu() {
        let duration: TimeInterval = globalSettings.isSlow ? 5.0 : .nan
        rootSwitchViewController?.transitionDuration = duration
        let title = "Root Lonely Menu"
        let vc = MenuViewController()
        vc.title = title
        rootSwitchViewController?.switchView(to: vc, animation: .flipFromLeft)
    }

    func globalFlipToRootNavTwice() {
        let duration: TimeInterval = globalSettings.isSlow ? 8.0 : .nan
        let delay: TimeInterval = globalSettings.isSlow ? 3.0 : 0.1
        rootSwitchViewController?.transitionDuration = duration
        globalFlipToRootNav()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.globalFlipToRootNav()
        }
    }

    @objc private func slowToggleAction(sender: UISwitch) {
        globalSettings.isSlow = sender.isOn
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return actions.count
        case 1:
            return 1
        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            let action = actions[indexPath.row]
            cell.textLabel?.text = action.title
            cell.accessoryType = .disclosureIndicator
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellId, for: indexPath) as! SwitchCell
            cell.textLabel?.text = "Slow"
            cell.selectionStyle = .none
            cell.control.isOn = globalSettings.isSlow
            cell.control.removeTarget(self, action: nil, for: .valueChanged)
            cell.control.addTarget(self, action: #selector(slowToggleAction), for: .valueChanged)
            return cell
        default:
            fatalError()
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        action.routine()
    }
}

private class SwitchCell : UITableViewCell {

    let control = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryView = control
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
