//
//  RootViewController.swift
//
//  Created by Gabriele Mondada on 29.01.19.
//  Copyright © 2019 Gabriele Mondada. MIT License.
//

import Foundation
import UIKit

private var instanceCount = 0

class RootNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Root Nav"

        let vc = MenuViewController()
        vc.title = "Root Menu - Instance \(instanceCount)"
        instanceCount += 1
        viewControllers = [vc]
    }

    override func viewWillAppear(_ animated: Bool) {
        print("Root: \(title ?? "<no title"): viewWillAppear")
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        print("Root: \(title ?? "<no title"): viewDidAppear")
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        print("Root: \(title ?? "<no title"): viewWillDisappear")
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        print("Root: \(title ?? "<no title"): viewDidDisappear")
        super.viewDidDisappear(animated)
    }
}

class RootViewController: VerbexSwitchViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.switchView(to: RootNavViewController())
    }
}
