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
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: .init(width: 12, height: 12))
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.white.cgColor
            layer.path = path.cgPath
            return layer
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
        addChildViewController(_segmentControl)
        view.addSubview(_segmentControl.view)
        _segmentControl.view.frame = CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.width, height: _segmentControl.ui.height)
        _segmentControl.didMove(toParentViewController: self)
    }
    
    func _setupViews() {
        view.addSubview(_contentView)
        _contentView.frame = _contentViewFrame
        
        addChildViewController(_contactsView)
        _contactsView.view.frame = _contentView.bounds
        _contactsView.didMove(toParentViewController: self)
        addChildViewController(_conversationView)
        _conversationView.view.frame = _contentView.bounds
        _conversationView.didMove(toParentViewController: self)
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