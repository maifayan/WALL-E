//
//  Account.Login.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import RxSwift
import EVE

extension Account.Login {
    final class View: UIViewController {
        private var _loginView: LoginView { return view as! LoginView }
        private let _loginSuccess: Account.LoginSuccess
        
        init(_ loginSuccess: @escaping Account.LoginSuccess) {
            _loginSuccess = loginSuccess
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func loadView() {
            view = R.nib.loginView().instantiate(withOwner: nil, options: nil).first as! UIView
        }
        
        deinit {
            log()
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
        _loginView.loginBtn.on(.touchUpInside) { [weak self] _ in
            self?._login()
        }
    }
}

private extension Account.Login.View {
    func _validateAndGetInfo() -> (nameOrPhone: String, password: String)? {
        let np = _loginView.namePhoneTF.validateAndGetText(minCount: 6, maxCount: 24, callback: ui.textFieldValidate)
        let p = _loginView.passwordTF.validateAndGetText(minCount: 6, maxCount: 24, callback: ui.textFieldValidate)
        guard
            let nameAndPhone = np,
            let password = p
        else { return nil }
        return (nameAndPhone, password)
    }
   
    func _login() {
        unowned let me = self
        Observable.just(me._validateAndGetInfo())
            .ignoreNil()
            .do(onNext: { _ in
                me.view.endEditing(true)
                me.showHUD()
            })
            .map { info in
                EVELoginInfo {
                    $0.nameOrPhone = info.nameOrPhone
                    $0.password = info.password
                }
            }
            .flatMap(EVE.workMapper(EVE.Account.shared.login))
            .subscribeOnMain(onNext: { result in
                me.dismissHUD()
                me._loginSuccess((result.token, result.contact.id_p))
            }, onError: {
                me.dismissHUD()
                me.showHUD(error: $0)
            })
            .disposed(by: rx.disposeBag)
    }
}

extension UI where Base: Account.Login.View {
    var invalidatedRightView: UIView {
        let ret = UIImageView(image: R.image.edit()?.withRenderingMode(.alwaysTemplate))
        ret.tintColor = UIColor.red.withAlphaComponent(0.45)
        return ret
    }
    var textFieldValidate: (UITextField, Bool) -> () {
        return { $0.rightView = $1 ? nil : self.invalidatedRightView }
    }
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
