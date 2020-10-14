//
//  MenuViewController.swift
//
//  Created by Gabriele Mondada on 29.01.19.
//  Copyright © 2019 Gabriele Mondada. MIT License.
//

import Foundation
import UIKit

struct Action {
    let title: String
    let routine: () -> Void
}

struct Transition {
    let title: String
    let animation: VerbexSwitchViewController.Animation
}

class MenuViewController: UITableViewController {

    private let actionCellId = "ActionCell"
    private let transitionCellId = "TransitionCell"
    private let switchCellId = "SwitchCell"
    private var actions = [Action]()
    private var transitions = [Transition]()
    private let checkmark = UIImage(systemName: "checkmark")

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
            Action(title: "Global Switch to Root Nav Twice (test interruptible transitions)") {
                [unowned self] in
                self.globalFlipToRootNavTwice()
            },
            Action(title: "Toggle Settings + Global Switch to Lonely Menu") {
                [unowned self] in
                self.globalFlipToLonelyMenu(toggleSettings: true)
            },
        ]

        transitions = [
            Transition(title: "None", animation: .none),
            Transition(title: "Fade", animation: .fade),
            Transition(title: "AntiFade", animation: .antiFade),
            Transition(title: "Flip From Left (non interruptible)", animation: .flipFromLeft),
            Transition(title: "Flip From Right (non interruptible)", animation: .flipFromRight),
            Transition(title: "Shift Left", animation: .shiftLeft),
            Transition(title: "Shift Right", animation: .shiftRight),
            Transition(title: "Shift Up", animation: .shiftUp),
            Transition(title: "Shift Down", animation: .shiftDown),
        ]

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: actionCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: transitionCellId)
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

    override var prefersStatusBarHidden: Bool {
        get { return globalSettings.prefersStatusBarHidden }
        set {
            globalSettings.prefersStatusBarHidden = newValue
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return globalSettings.preferredStatusBarStyle }
        set {
            globalSettings.preferredStatusBarStyle = newValue
            UIView.animate(withDuration: 0.2) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        get { return globalSettings.prefersHomeIndicatorAutoHidden }
        set {
            globalSettings.prefersHomeIndicatorAutoHidden = newValue
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        get { return globalSettings.preferredScreenEdgesDeferringSystemGestures }
        set {
            globalSettings.preferredScreenEdgesDeferringSystemGestures = newValue
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
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

    private func applySettings() {
        let duration: TimeInterval = globalSettings.isSlow ? 5.0 : .nan
        rootSwitchViewController?.transitionDuration = duration
        rootSwitchViewController?.asksChildrenForStatusBarHidden
            = globalSettings.reflectChildStatusBarHidden
        rootSwitchViewController?.asksChildrenForStatusBarStyle
            = globalSettings.reflectChildStatusBarStyle
        rootSwitchViewController?.asksChildrenForHomeIndicatorAutoHidden
            = globalSettings.reflectChildHomeIndicatorAutoHidden
        rootSwitchViewController?.asksChildrenForScreenEdgesDeferringSystemGestures
            = globalSettings.reflectChildScreenEdgesDeferringSystemGestures
        rootSwitchViewController?.animatesStatusBarAppearanceUpdates
            = globalSettings.animateStatusBarAppearanceUpdates
    }

    func globalFlipToRoot() {
        applySettings()
        let vc = RootViewController()
        rootSwitchViewController?.switchView(to: vc, animation: globalSettings.animation)
    }

    func globalFlipToRootNav() {
        applySettings()
        let vc = RootNavViewController()
        rootSwitchViewController?.switchView(to: vc, animation: globalSettings.animation)
    }

    func globalFlipToLonelyMenu(toggleSettings: Bool = false) {
        applySettings()
        if toggleSettings {
            globalSettings.prefersStatusBarHidden = !globalSettings.prefersStatusBarHidden
            globalSettings.preferredStatusBarStyle = globalSettings.preferredStatusBarStyle == .lightContent ? .darkContent : .lightContent
            globalSettings.prefersHomeIndicatorAutoHidden = !globalSettings.prefersHomeIndicatorAutoHidden
            globalSettings.preferredScreenEdgesDeferringSystemGestures = globalSettings.preferredScreenEdgesDeferringSystemGestures == [] ? .all : []
        }
        let title = "Root Lonely Menu"
        let vc = MenuViewController()
        vc.title = title
        rootSwitchViewController?.switchView(to: vc, animation: globalSettings.animation)
    }

    func globalFlipToRootNavTwice() {
        let delay: TimeInterval = globalSettings.isSlow ? 2.0 : 0.1
        globalFlipToRootNav()
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.globalFlipToRootNav()
        }
    }

    @objc private func slowToggleAction(sender: UISwitch) {
        globalSettings.isSlow = sender.isOn
    }

    @objc private func reflectChildStatusBarHiddenToggleAction(sender: UISwitch) {
        globalSettings.reflectChildStatusBarHidden = sender.isOn
    }

    @objc private func reflectChildStatusBarStyleToggleAction(sender: UISwitch) {
        globalSettings.reflectChildStatusBarStyle = sender.isOn
    }

    @objc private func reflectChildHomeIndicatorAutoHiddenToggleAction(sender: UISwitch) {
        globalSettings.reflectChildHomeIndicatorAutoHidden = sender.isOn
    }

    @objc private func reflectChildScreenEdgesDeferringSystemGesturesToggleAction(sender: UISwitch) {
        globalSettings.reflectChildScreenEdgesDeferringSystemGestures = sender.isOn
    }

    @objc private func animateStatusBarAppearanceUpdatesToggleAction(sender: UISwitch) {
        globalSettings.animateStatusBarAppearanceUpdates = sender.isOn
    }

    @objc private func statusBarHiddenToggleAction(sender: UISwitch) {
        prefersStatusBarHidden = sender.isOn
    }

    @objc private func statusBarForLightContentToggleAction(sender: UISwitch) {
        preferredStatusBarStyle = sender.isOn ? .lightContent : .darkContent
    }

    @objc private func homeIndicatorAutoHiddenToggleAction(sender: UISwitch) {
        prefersHomeIndicatorAutoHidden = sender.isOn
    }

    @objc private func deferringSystemGesturesToggleAction(sender: UISwitch) {
        preferredScreenEdgesDeferringSystemGestures = sender.isOn ? .all : []
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return actions.count
        case 1:
            return transitions.count
        case 2:
            return 6
        case 3:
            return 4
        default:
            fatalError()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: actionCellId, for: indexPath)
            let action = actions[indexPath.row]
            cell.textLabel?.text = action.title
            cell.accessoryType = .disclosureIndicator
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: transitionCellId, for: indexPath)
            let transition = transitions[indexPath.row]
            cell.textLabel?.text = transition.title
            cell.imageView?.image = checkmark
            cell.imageView?.isHidden = transition.animation != globalSettings.animation
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellId, for: indexPath) as! SwitchCell
            cell.selectionStyle = .none
            cell.control.removeTarget(self, action: nil, for: .valueChanged)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Slow"
                cell.control.isOn = globalSettings.isSlow
                cell.control.addTarget(self, action: #selector(slowToggleAction), for: .valueChanged)
            case 1:
                cell.textLabel?.text = "Reflect Child Status Bar Hidden"
                cell.control.isOn = globalSettings.reflectChildStatusBarHidden
                cell.control.addTarget(self, action: #selector(reflectChildStatusBarHiddenToggleAction), for: .valueChanged)
            case 2:
                cell.textLabel?.text = "Reflect Child Status Bar Style"
                cell.control.isOn = globalSettings.reflectChildStatusBarStyle
                cell.control.addTarget(self, action: #selector(reflectChildStatusBarStyleToggleAction), for: .valueChanged)
            case 3:
                cell.textLabel?.text = "Reflect Child Home Indicator Auto Hidden"
                cell.control.isOn = globalSettings.reflectChildHomeIndicatorAutoHidden
                cell.control.addTarget(self, action: #selector(reflectChildHomeIndicatorAutoHiddenToggleAction), for: .valueChanged)
            case 4:
                cell.textLabel?.text = "Reflect Child Screen Edges Deferring System Gestures"
                cell.control.isOn = globalSettings.reflectChildScreenEdgesDeferringSystemGestures
                cell.control.addTarget(self, action: #selector(reflectChildScreenEdgesDeferringSystemGesturesToggleAction), for: .valueChanged)
            case 5:
                cell.textLabel?.text = "Animate Status Bar Appearance Updates"
                cell.control.isOn = globalSettings.animateStatusBarAppearanceUpdates
                cell.control.addTarget(self, action: #selector(animateStatusBarAppearanceUpdatesToggleAction), for: .valueChanged)
            default:
                fatalError()
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: switchCellId, for: indexPath) as! SwitchCell
            cell.selectionStyle = .none
            cell.control.removeTarget(self, action: nil, for: .valueChanged)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Status Bar Hidden"
                cell.control.isOn = prefersStatusBarHidden
                cell.control.addTarget(self, action: #selector(statusBarHiddenToggleAction), for: .valueChanged)
            case 1:
                cell.textLabel?.text = "Status Bar For Light Content"
                cell.control.isOn = preferredStatusBarStyle == .lightContent
                cell.control.addTarget(self, action: #selector(statusBarForLightContentToggleAction), for: .valueChanged)
            case 2:
                cell.textLabel?.text = "Home Indicator Auto Hidden"
                cell.control.isOn = prefersHomeIndicatorAutoHidden
                cell.control.addTarget(self, action: #selector(homeIndicatorAutoHiddenToggleAction), for: .valueChanged)
            case 3:
                cell.textLabel?.text = "Defer System Gestures"
                cell.control.isOn = globalSettings.preferredScreenEdgesDeferringSystemGestures != []
                cell.control.addTarget(self, action: #selector(deferringSystemGesturesToggleAction), for: .valueChanged)
            default:
                fatalError()
            }
            return cell
        default:
            fatalError()
        }
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let action = actions[indexPath.row]
            action.routine()
        case 1:
            tableView.deselectRow(at: indexPath, animated: true)
            globalSettings.animation = transitions[indexPath.row].animation
            for (index, transition) in transitions.enumerated() {
                if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 1)) {
                    cell.imageView?.isHidden = transition.animation != globalSettings.animation
                }
            }
        default:
            break
        }
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
