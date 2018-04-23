//
//  Menu.View.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/22.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import Tactile

extension Menu {
    final class View: UIViewController {
        enum MenuAction {
            case newRobot
            case theme
            case settings
        }
        
        private lazy var _contentView: _MenuContentView = {
            let view = R.nib.menuContentView().instantiate(withOwner: nil, options: nil).first as! _MenuContentView
            view.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
            return view
        }()
        
        private let _actionCallback: (MenuAction) -> ()
        
        init(actionCallback: @escaping (MenuAction) -> ()) {
            _actionCallback = actionCallback
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension Menu.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(_contentView)
        _layout()
        
        let action: (MenuAction) -> () -> () = { [weak self] action in { self?._actionCallback(action) } }
        _contentView.newRobotBtn.on(.touchUpInside, const(action(.newRobot)))
        _contentView.themeBtn.on(.touchUpInside, const(action(.theme)))
        _contentView.settingsBtn.on(.touchUpInside, const(action(.settings)))
    }
}

private extension Menu.View {
    func _layout() {
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        let bottomAnchor: NSLayoutYAxisAnchor = {
            if #available(iOS 11, *) {
                return view.safeAreaLayoutGuide.bottomAnchor
            } else {
                return view.bottomAnchor
            }
        }()
        NSLayoutConstraint.activate([
            _contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            _contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            _contentView.topAnchor.constraint(equalTo: view.topAnchor),
            _contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

class _MenuContentView: UIView {
    @IBOutlet weak var newRobotBtn: UIButton!
    @IBOutlet weak var themeBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newRobotBtn.layout(with: .vImageLabel, space: 16)
        themeBtn.layout(with: .vImageLabel, space: 16)
        settingsBtn.layout(with: .vImageLabel, space: 16)
    }
}

class _ColorSelectView: UIViewController {
    override func awakeFromNib() {
        super.awakeFromNib()
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overCurrentContext
        
        view.on(UITapGestureRecognizer()) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func on(_ sender: UIButton) {
        Theme.shared.refresh(keyPath: \.mainColor, to: sender.backgroundColor ?? .white)
        dismiss(animated: true, completion: nil)
    }
}
