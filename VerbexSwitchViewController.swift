/*
 * Copyright 2019 Gabriele Mondada
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

class VerbexSwitchViewController: UIViewController {

    var child: UIViewController?
    let visibility = VerbexViewControllerVisibility()
    private var currentTransitionLogic: TransitionLogic?

    enum Animation {
        case none
        case fade     // the new view is faded in
        case antiFade // the old view is faded out
        case flipFromLeft
        case flipFromRight
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        child?.view.frame = self.view.bounds
    }

    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        visibility.setState(.appearing, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visibility.setState(.visible, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        visibility.setState(.disappearing, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        visibility.setState(.hidden, animated: animated)
    }

    func switchView(to viewController: UIViewController, animation: Animation = .none) {

        let completion = {
            self.currentTransitionLogic = nil
        }

        let animationLogic: TransitionLogic
        switch animation {
        case .none:
            animationLogic = UnanimatedTransitionLogic(switchViewController: self,
                                                       newViewController: viewController,
                                                       completion: completion)
        case .fade:
            animationLogic = FadeAnimationLogic(switchViewController: self,
                                                newViewController: viewController,
                                                completion: completion)
        case .antiFade:
            let anim = FadeAnimationLogic(switchViewController: self,
                                          newViewController: viewController,
                                          completion: completion)
            anim.antiFade = true
            animationLogic = anim
        case .flipFromLeft:
            let flip = FlipAnimationLogic(switchViewController: self,
                                          newViewController: viewController,
                                          completion: completion)
            flip.fromRight = false
            animationLogic = flip
        case .flipFromRight:
            let flip = FlipAnimationLogic(switchViewController: self,
                                          newViewController: viewController,
                                          completion: completion)
            flip.fromRight = true
            animationLogic = flip
        }

        currentTransitionLogic?.terminate()
        currentTransitionLogic = animationLogic

        animationLogic.start()
    }
}

private class TransitionLogic {
    var switchViewController: VerbexSwitchViewController
    var oldViewController: UIViewController?
    var newViewController: UIViewController
    var isRunning = false
    private var completion: (()->Void)?

    init(switchViewController: VerbexSwitchViewController, newViewController: UIViewController, completion: (()->Void)? = nil) {
        self.switchViewController = switchViewController
        self.newViewController = newViewController
        self.completion = completion
    }

    func start() {
        isRunning = true

        let old = switchViewController.child
        oldViewController = old

        let new = newViewController
        switchViewController.child = new

        beginTransition(old: old, new: new, animated: true)

        handleViewTransition(oldView: old?.view, newView: new.view) {
            self.finishTransition(old: old, new: new, animated: true)
            assert(self.isRunning);
            self.isRunning = false
        }
    }

    /**
     * Force terminating the animation and call the completion handler.
     */
    func terminate() {
        if isRunning {
            abortViewTransition(oldView: oldViewController?.view, newView: newViewController.view)
            finishTransition(old: oldViewController, new: newViewController, animated: true)
            isRunning = false
        }
    }

    /**
     * Sub-classes must implement this method to add the new view to the parent
     * view and to do the right layout / animation.
     */
    func handleViewTransition(oldView: UIView?, newView: UIView, completion: @escaping ()->Void) {
        fatalError("not implemented")
    }

    /**
     * Abort the transition. The completion given to handleViewTransition() will
     * not be invoked.
     */
    func abortViewTransition(oldView: UIView?, newView: UIView) {
        fatalError("not implemented")
    }

    private func beginTransition(old: UIViewController?, new: UIViewController, animated: Bool) {
        print("begin trans: new=\(new)")

        switchViewController.visibility.addChild(new)

        // start removing previous view controller
        old?.willMove(toParent: nil)

        // start adding new view controller
        switchViewController.addChild(new)

        // inform the old view controller that it will disappear
        if let old = old {
            switchViewController.visibility.child(old).setState(.disappearing, animated: animated)
        }

        // inform the new view controller that it will appear
        switchViewController.visibility.child(new).setState(.appearing, animated: animated)
    }

    private func finishTransition(old: UIViewController?, new: UIViewController, animated: Bool) {
        print("finish trans: new=\(new)")

        // inform about end of disappearing transition
        if let old = old {
            self.switchViewController.visibility.child(old).setState(.hidden, animated: animated)
            old.view.removeFromSuperview()
            old.removeFromParent()
            self.switchViewController.visibility.removeChild(old)
        }

        // inform about end of appearing transition
        self.switchViewController.visibility.child(new).setState(.visible, animated: animated)
        new.didMove(toParent: self.switchViewController)

        completion?()
        completion = nil
    }
}

private class UnanimatedTransitionLogic: TransitionLogic {
    override func handleViewTransition(oldView: UIView?, newView: UIView, completion: @escaping ()->Void) {
        let parent = switchViewController.view!
        let r = parent.bounds
        newView.autoresizingMask = []
        newView.translatesAutoresizingMaskIntoConstraints = true
        newView.frame = r;
        parent.addSubview(newView)
        completion()
    }
}

/**
 * Transition logic that manages an animation thanks to the UIView animation
 * capabilities (on top of Core Layer).
 */
private class AnimationLogic: TransitionLogic {

    private var aborted = false

    override func handleViewTransition(oldView: UIView?, newView: UIView, completion: @escaping ()->Void) {

        preAnimation(oldView: oldView, newView: newView)

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { self.animation(oldView: oldView, newView: newView, expedited: false) },
                       completion: { (finished: Bool) in
                        if !self.aborted {
                            self.postAnimation(oldView: oldView, newView: newView)
                            completion()
                        }
        })
    }

    override func abortViewTransition(oldView: UIView?, newView: UIView) {
        assert(!aborted)
        aborted = true
        self.animation(oldView: oldView, newView: newView, expedited: true)
        self.postAnimation(oldView: oldView, newView: newView)
    }

    var duration: TimeInterval {
        return 0.25
    }

    func preAnimation(oldView: UIView?, newView: UIView) {
    }

    /**
     * This method has to set the view properties target values.
     */
    func animation(oldView: UIView?, newView: UIView, expedited: Bool) {
    }

    func postAnimation(oldView: UIView?, newView: UIView) {
    }
}

private class FadeAnimationLogic: AnimationLogic {

    var antiFade = false

    override func preAnimation(oldView: UIView?, newView: UIView) {
        let parent = switchViewController.view!

        // attach new view
        let r = parent.bounds
        newView.autoresizingMask = []
        newView.translatesAutoresizingMaskIntoConstraints = true
        newView.frame = r;

        if antiFade, let oldView = oldView {
            newView.alpha = 1
            parent.insertSubview(newView, belowSubview: oldView)
        } else {
            newView.alpha = 0
            parent.addSubview(newView)
        }
    }

    override func animation(oldView: UIView?, newView: UIView, expedited: Bool) {
        let r = switchViewController.view.bounds
        newView.frame = r

        if antiFade, let oldView = oldView {
            oldView.alpha = 0
        } else {
            newView.alpha = 1
        }
    }
}

private class FlipAnimationLogic: TransitionLogic {

    private let duration: TimeInterval = 0.7
    
    var fromRight = false

    override func handleViewTransition(oldView optOldView: UIView?, newView: UIView, completion: @escaping ()->Void) {
        let parent = switchViewController.view!
        let r = parent.bounds

        let oldView: UIView
        if let v = optOldView {
            oldView = v
        } else {
            oldView = UIView()
            oldView.isHidden = true
            oldView.alpha = 0
            oldView.autoresizingMask = []
            oldView.translatesAutoresizingMaskIntoConstraints = true
            oldView.frame = r
            parent.addSubview(oldView)
        }

        newView.autoresizingMask = []
        newView.translatesAutoresizingMaskIntoConstraints = true
        newView.frame = r

        UIView.transition(from: oldView,
                          to: newView,
                          duration: duration,
                          options: [fromRight ? .transitionFlipFromRight : .transitionFlipFromLeft, .curveEaseInOut],
                          completion: { _ in completion() })
    }
}
