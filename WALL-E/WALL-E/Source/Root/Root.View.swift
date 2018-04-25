//
//  Root.View.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/22.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import Tactile
import RxSwift

extension Root {
    final class View: UIViewController {
        private lazy var _mainView = Main.View()
        
        private lazy var _menuView = Menu.View { [weak self] action in
            switch action {
            case .newRobot:
                self?.present(Chat.View(), animated: true, completion: nil)
            case .theme:
                self?._switchTheme()
            case .settings: ()
            }
        }
        
        private lazy var _menuButton: UIButton = {
            let button = UIButton(type: .system)
            
            let path = UIBezierPath(roundedRect: .init(origin: .zero, size: ui.menuButtonSize), cornerRadius: 0.5 * ui.menuButtonSize.width)
            let backgroundLayer = CAShapeLayer()
            backgroundLayer.ui.adapt(themeKeyPath: \.mainColor, for: \.fillColor) { $0.cgColor }
            backgroundLayer.path = path.cgPath
            button.layer.insertSublayer(backgroundLayer, below: button.imageView?.layer)
            button.setShadow(color: .gray, offSet: CGSize(width: 5, height: 5), radius: 6, opacity: 0.6)

            button.setImage(R.image.menu()?.withRenderingMode(.alwaysOriginal), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: -3, right: 0)
            return button
        }()
        
        private var _isShowedMenu = false {
            didSet {
                guard _isShowedMenu != oldValue else { return }
                _switchShowMenu(_isShowedMenu)
            }
        }
    }
}

extension Root.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        ui.adapt(themeKeyPath: \.mainColor, for: \.view.backgroundColor)
        addChildViewController(_menuView)
        view.addSubview(_menuView.view)
        _menuView.didMove(toParentViewController: self)
        
        addChildViewController(_mainView)
        view.addSubview(_mainView.view)
        _mainView.view.frame = view.bounds
        _mainView.view.setShadow(color: .gray, offSet: CGSize(width: 0, height: 1), radius: 8, opacity: 0.5)
        _mainView.didMove(toParentViewController: self)
        _setupMenuButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _menuView.view.frame = CGRect(x: 0, y: view.height - ui.menuViewHeight, width: view.width, height: ui.menuViewHeight)
    }
}

private extension Root.View {
    func _setupMenuButton() {
        view.addSubview(_menuButton)
        _menuButton.translatesAutoresizingMaskIntoConstraints = false
        let bottomAnchor: NSLayoutYAxisAnchor = {
            if #available(iOS 11, *) {
                return view.safeAreaLayoutGuide.bottomAnchor
            } else {
                return view.bottomAnchor
            }
        }()
        
        NSLayoutConstraint.activate([
            _menuButton.widthAnchor.constraint(equalToConstant: ui.menuButtonSize.width),
            _menuButton.heightAnchor.constraint(equalToConstant: ui.menuButtonSize.height),
            _menuButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -ui.menuButtonSpacing),
            _menuButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ui.menuButtonSpacing)
        ])
        
        _menuButton.on(.touchUpInside) { [weak self] btn in
            guard let `self` = self else { return }
            self._isShowedMenu = !self._isShowedMenu
            
            guard btn.alpha != 1 else { return }
            UIView.animate(withDuration: 0.25) {
                btn.alpha = 1
            }
        }
        
        _bindMenuDisplayControllers(_mainView)
    }
    
    func _switchShowMenu(_ flag: Bool) {
        _mainView.view.isUserInteractionEnabled = !flag
        let transformForMainViewAndMenuButton = flag ? CGAffineTransform(translationX: 0, y: -ui.menuViewHeight) : .identity
        let menuButtonImgae = flag ? R.image.close_menu() : R.image.menu()
        _menuButton.setImage(menuButtonImgae?.withRenderingMode(.alwaysOriginal), for: .normal)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.55, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self._mainView.view.transform = transformForMainViewAndMenuButton
            self._menuButton.transform = transformForMainViewAndMenuButton
        })
        _mainView.blur(flag)
    }
    
    func _bindMenuDisplayControllers(_ controller: MenuButtonDisplayController) {
        controller.showMenuButton.subscribe(onNext: { [weak self] show in
            UIView.animate(withDuration: 0.25) {
                self?._menuButton.alpha = show ? 1 : 0.4
            }
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - Events
private extension Root.View {
    func _switchTheme() {
        let vc = R.nib.colorSelectView().instantiate(withOwner: nil, options: nil).first as! UIViewController
        present(vc, animated: true, completion: nil)
    }
}

extension UI where Base: Root.View {
    var menuButtonSpacing: CGFloat { return 35 }
    var menuButtonSize: CGSize { return .init(width: 68, height: 68) }
    var menuViewHeight: CGFloat {
        let safeBottomSpacing: CGFloat = {
            if #available(iOS 11, *) {
                return base.view.safeAreaInsets.bottom
            } else {
                return 0
            }
        }()
        return 160 + safeBottomSpacing
    }
}

// MARK: - MenuButtonDisplayController
protocol MenuButtonDisplayController {
    var showMenuButton: Observable<Bool> { get }
}
