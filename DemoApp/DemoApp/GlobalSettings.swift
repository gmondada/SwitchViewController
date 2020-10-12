//
//  GlobalSettings.swift
//
//  Created by Gabriele Mondada on 12.10.20.
//  Copyright © 2020 Gabriele Mondada. MIT License.
//

import Foundation

var globalSettings = GlobalSettings()

struct GlobalSettings {
    var isSlow = false
    var animation: VerbexSwitchViewController.Animation = .flipFromRight
}
