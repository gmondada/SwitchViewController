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
    private var actions = [Action]()

    override func viewDidLoad() {
        super.viewDidLoad()

        actions = [
            Action(title: "Push") {
                self.push()
            },
            Action(title: "Global Flip to Root Nav") {
                self.globalFlipToRootNav()
            },
            Action(title: "Global Flip to Lonely Menu") {
                self.globalFlipToLonelyMenu()
            },
        ]

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
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

    func globalFlipToRoot() {
        let vc = RootViewController()
        var parent: UIViewController = self
        while true {
            if let p = parent.parent {
                parent = p
            } else {
                break
            }
        }
        if let p = parent as? VerbexSwitchViewController {
            p.switchView(to: vc, animation: .flipFromLeft)
        }
    }

    func globalFlipToRootNav() {
        let vc = RootNavViewController()
        var parent: UIViewController = self
        while true {
            if let p = parent.parent {
                parent = p
            } else {
                break
            }
        }
        if let p = parent as? VerbexSwitchViewController {
            p.switchView(to: vc, animation: .flipFromLeft)
        }
    }

    func globalFlipToLonelyMenu() {
        let title = "Root Lonely Menu"
        let vc = MenuViewController()
        vc.title = title
        var parent: UIViewController = self
        while true {
            if let p = parent.parent {
                parent = p
            } else {
                break
            }
        }
        if let p = parent as? VerbexSwitchViewController {
            p.switchView(to: vc, animation: .flipFromLeft)
        }
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let action = actions[indexPath.row]
        cell.textLabel?.text = action.title
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = actions[indexPath.row]
        action.routine()
    }
}
