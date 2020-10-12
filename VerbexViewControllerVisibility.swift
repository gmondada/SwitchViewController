/*
 * Copyright (c) 2019 Gabriele Mondada
 *
 * MIT License
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation
import UIKit

public enum VerbexViewControllerVisibilityState {
    case hidden
    case visible
    case appearing
    case disappearing
}

protocol VerbexViewControllerVisibilityStateHolder: class {
    var state: VerbexViewControllerVisibilityState { get set }
    func setState(_: VerbexViewControllerVisibilityState, animated: Bool)
}

class VerbexViewControllerVisibility {

    private weak var viewController: UIViewController?

    private var children = [Child]()

    private var _state: VerbexViewControllerVisibilityState = .hidden

    var state: VerbexViewControllerVisibilityState {
        get {
            return _state
        }
        set {
            setState(newValue, animated: false)
        }
    }

    func setState(_ state: VerbexViewControllerVisibilityState, animated: Bool) {
        _state = state
        for child in children {
            child.setParentState(state, animated: animated)
        }
    }

    public init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }

    public func addChild(_ vc: UIViewController) {
        let child = Child(vc)
        child.parentState = state
        children.append(child)
    }

    public func removeChild(_ vc: UIViewController) {
        if let index = children.firstIndex(where: {$0.viewController == vc}) {
            assert(children[index].state == .hidden)
            children.remove(at: index)
        }
    }

    public func child(_ vc: UIViewController) -> VerbexViewControllerVisibilityStateHolder {
        return children.first(where: {$0.viewController == vc})!
    }
}

private class Child: VerbexViewControllerVisibilityStateHolder {

    var viewController: UIViewController? = nil

    private var _parentState: VerbexViewControllerVisibilityState = .hidden

    var parentState: VerbexViewControllerVisibilityState {
        get {
            return _parentState
        }
        set {
            setParentState(newValue, animated: false)
        }
    }

    func setParentState(_ newState: VerbexViewControllerVisibilityState, animated: Bool) {
        if newState != _parentState {
            _parentState = newState
            updateVisibility(animated: animated)
        }
    }

    private var _state: VerbexViewControllerVisibilityState = .hidden

    var state: VerbexViewControllerVisibilityState {
        get {
            return _state
        }
        set {
            setState(newValue, animated: false)
        }
    }

    func setState(_ newState: VerbexViewControllerVisibilityState, animated: Bool) {
        if newState != _state {
            _state = newState
            updateVisibility(animated: animated)
        }
    }

    init(_ viewController: UIViewController) {
        self.viewController = viewController
    }

    private var currentState: VerbexViewControllerVisibilityState = .hidden

    private func updateVisibility(animated: Bool) {

        // compute target state combining parent and self state

        let targetState: VerbexViewControllerVisibilityState
        if parentState == .hidden || state == .hidden {
            targetState = .hidden
        } else if parentState == .visible {
            targetState = state
        } else if state == .visible {
            targetState = parentState
        } else if state == parentState {
            targetState = state
        } else {
            // state == .appearing && parentState == .disappearing or vice-versa
            switch currentState {
            case .hidden:
                targetState = .appearing
            case .visible:
                targetState = .disappearing
            default:
                targetState = currentState
            }
        }

        // state machine

        while currentState != targetState {

            // update current state (move by one step)
            switch currentState {
            case .hidden:
                if targetState != .hidden {
                    currentState = .appearing
                }
            case .visible:
                if targetState != .visible {
                    currentState = .disappearing
                }
            case .appearing:
                if targetState == .visible {
                    currentState = .visible
                } else {
                    currentState = .disappearing
                }
            case .disappearing:
                if targetState == .hidden {
                    currentState = .hidden
                } else {
                    currentState = .appearing
                }
            }

            // notify
            switch currentState {
            case .hidden, .visible:
                viewController!.endAppearanceTransition()
            case .appearing:
                viewController!.beginAppearanceTransition(true, animated: animated)
            case .disappearing:
                viewController!.beginAppearanceTransition(false, animated: animated)
            }
        }
    }
}
