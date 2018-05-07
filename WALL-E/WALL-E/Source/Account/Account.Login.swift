//
//  Account.Login.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

extension Account.Login {
    final class View: UIViewController {
        private var _loginView: LoginView { return view as! LoginView }
        
        override func loadView() {
            view = R.nib.loginView().instantiate(withOwner: nil, options: nil).first as! UIView
        }
        
        deinit {
            _loginView.cancelAdaptingKeyboard()
        }
    }
}

extension Account.Login.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tap { $0.view?.endEditing(true) }
        _loginView.registerBtn.on(.touchUpInside) { [weak nc = navigationController] _ in
            nc?.pushViewController(Account.Register.View(), animated: true)
        }
        _loginView.adaptToKeyboard(minSpacingToKeyboard: 20, reference: _loginView.loginBtn)
//        _loginView.loginBtn.on(.touchUpInside)
    }
}

private extension Account.Login.View {
    
}

final class LoginView: UIView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var namePhoneTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui.adapt(themeKeyPath: \.mainColor, for: \.backgroundColor)
    }
}
