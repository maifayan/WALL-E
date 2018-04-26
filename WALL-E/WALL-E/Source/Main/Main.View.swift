//
//  Main.View.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/22.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import RxSwift

extension Main {
    final class View: UIViewController {
        private lazy var _contactsView = Contacts.View()
        private lazy var _conversationView = Conversations.View()
        private lazy var _contentView: UIView = {
            let view = UIView()
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            return view
        }()
        private lazy var _segmentControl = SegmentControl(titles: ("CONVERSATIONS", "CONTACTS"), callback: _switchContentView)
        private lazy var _backgroundLayer: CALayer = {
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: .init(width: 16, height: 16))
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.white.cgColor
            layer.path = path.cgPath
            return layer
        }()
        private lazy var _blurView: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .light)
            let view = UIVisualEffectView(effect: effect)
            view.clipsToBounds = true
            view.layer.cornerRadius = 16
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.isHidden = true
            view.alpha = 0
            return view
        }()
    }
}

extension Main.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.layer.addSublayer(_backgroundLayer)
        _addSegmentControl()
        _setupViews()
        _setupGestureRecognizer()
    }

    func blur(_ flag: Bool) {
        guard (flag && _blurView.isHidden) || (!flag && !_blurView.isHidden) else { return }
        if flag {
            _blurView.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self._blurView.alpha = 0.5
            }
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self._blurView.alpha = 0
            }) { _ in
                self._blurView.isHidden = true
            }
        }
    }
}

private extension Main.View {
    private var _switchContentView: (Main.SegmentControl.SelectedSide) -> () {
        return { [weak self] side in
            guard let `self` = self else { return }
            let transition: CATransition = {
                $0.type = "oglFlip"
                $0.duration = 0.35
                $0.subtype = side == .left ? kCATransitionFromLeft : kCATransitionFromRight
                return $0
            }(CATransition())
            
            if side == .left {
                self._contactsView.view.removeFromSuperview()
                self._contentView.addSubview(self._conversationView.view)
            } else {
                self._conversationView.view.removeFromSuperview()
                self._contentView.addSubview(self._contactsView.view)
            }
            self._contentView.layer.add(transition, forKey: nil)
        }
    }
}

private extension Main.View {
    func _addSegmentControl() {
        add(_segmentControl, viewFrame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.width, height: _segmentControl.ui.height))
    }
    
    func _setupViews() {
        view.addSubview(_contentView)
        _contentView.frame = _contentViewFrame
        
        add(_contactsView, shouldAddView: false, viewFrame: _contentView.bounds)
        add(_conversationView, shouldAddView: false, viewFrame: _contentView.bounds)

        view.addSubview(_blurView)
        _blurView.frame = view.bounds
    }
    
    func _setupGestureRecognizer() {
        let handler: (Main.SegmentControl.SelectedSide) -> () -> () = { [weak self] side in { self?._segmentControl.selectedSide = side } }
        let create: (UISwipeGestureRecognizerDirection) -> UISwipeGestureRecognizer = {
            let ret = UISwipeGestureRecognizer()
            ret.direction = $0
            return ret
        }
        view.on(create(.left), const(handler(.right)))
        view.on(create(.right), const(handler(.left)))
    }

    var _contentViewFrame: CGRect {
        let y = UIApplication.shared.statusBarFrame.height + _segmentControl.ui.height
        return CGRect(x: 0, y: y, width: view.width, height: view.height - y)
    }
}

extension Main.View: MenuButtonDisplayController {
    var showMenuButton: Observable<Bool> {
        return Observable.merge(_contactsView.showMenuButton, _conversationView.showMenuButton)
    }
}
