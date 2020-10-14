//
//  GlobalSettings.swift
//
//  Created by Gabriele Mondada on 12.10.20.
//  Copyright © 2020 Gabriele Mondada. MIT License.
//

import Foundation
import UIKit

var globalSettings = GlobalSettings()

struct GlobalSettings {
    // for verbex switch view controller
    var isSlow = false
    var animation: VerbexSwitchViewController.Animation = .flipFromRight
    var reflectChildStatusBarHidden = false
    var reflectChildStatusBarStyle = false
    var reflectChildHomeIndicatorAutoHidden = false
    var reflectChildScreenEdgesDeferringSystemGestures = false

    // for menu view controller
    var prefersStatusBarHidden = false
    var preferredStatusBarStyle = UIStatusBarStyle.darkContent
    var prefersHomeIndicatorAutoHidden = false
    var preferredScreenEdgesDeferringSystemGestures: UIRectEdge = []
}
