//
//  Account.Register.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import EVE
import JGProgressHUD

extension Account.Register {
    final class View: UIViewController {
        private var _registerView: RegisterView { return view as! RegisterView }
        private var _avatarURL: URL?

        override func loadView() {
            view = R.nib.registerView().instantiate(withOwner: nil, options: nil).first as! UIView
        }
        
        deinit {
            log()
        }
    }
}

extension Account.Register.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        _registerView.tap { $0.view?.endEditing(true) }
        _registerView.backToLoginBtn.on(.touchUpInside) { [weak nc = navigationController] _ in
            nc?.popViewController(animated: true)
        }
        _registerView.adaptToKeyboard(minSpacingToKeyboard: 20, reference: _registerView.registerBtn)
        if #available(iOS 11, *) {
            _setupPicker()
        }
        _registerView.registerBtn.on(.touchUpInside) { [weak self] _ in
            self?._register()
        }
    }
}

private extension Account.Register.View {
    @available(iOS 11, *)
    func _setupPicker() {
        unowned let me = self
        let pickedImage = _registerView.avatarUploadView.onTap
            .flatMap(const(UIImagePickerController.pick(on: me) {
                $0.allowsEditing = false
                $0.sourceType = .photoLibrary
            }))
            .share(replay: 1)
        
        pickedImage.map(second).bind(to: _registerView.avatarUploadView.imageObserver).disposed(by: rx.disposeBag)
        pickedImage.map(first).subscribe(onNext: { [weak self] in self?._avatarURL = $0 }).disposed(by: rx.disposeBag)
    }
    
    func _validateAvatarAndGetURL() -> URL? {
        _registerView.avatarUploadView.isOK = _avatarURL != nil
        return _avatarURL
    }
    
    func _validateAndGetTextInfo() -> (phone: String, name: String, password: String, avatarPath: String)? {
        let p = _registerView.phoneTF.validateAndGetText(minCount: 11, maxCount: 11, callback: ui.textFieldValidate)
        let n = _registerView.nameTF.validateAndGetText(minCount: 3, maxCount: 24, callback: ui.textFieldValidate)
        let pa = _registerView.passwordTF.validateAndGetText(minCount: 6, maxCount: 24, callback: ui.textFieldValidate)
        let r = _registerView.repeatPasswordTF.validateAndGetText(minCount: 6, maxCount: 24, callback: ui.textFieldValidate)
        let a = _validateAvatarAndGetURL()
        if pa != r {
            _registerView.passwordTF.rightView = ui.invalidatedRightView
            _registerView.repeatPasswordTF.rightView = ui.invalidatedRightView
            return nil
        }
        guard
            let phone = p,
            let name = n,
            let password = pa,
            let avatar = a
        else { return nil }
        return (phone, name, password, avatar.path)
    }
    
    func _register() {
        unowned let me = self
        Observable.just(me._validateAndGetTextInfo())
            .ignoreNil()
            .do(onNext: { _ in
                me.view.endEditing(true)
                me.showHUD()
            })
            .flatMap { info in
                me._uploadAvatar(path: info.avatarPath)
                    .map { iconURL in
                        EVEUserRegisterInfo {
                            $0.name = info.name
                            $0.phone = info.phone
                            $0.password = info.password
                            $0.iconURL = iconURL
                        }
                    }
            }
            .flatMap(EVE.workMapper(EVE.Account.shared.register))
            .subscribeOnMain(onNext: { _ in
                me.dismissHUD()
                me.navigationController?.showHUD(successText: "Register success")
                me.navigationController?.popViewController(animated: true)
            }, onError: {
                me.dismissHUD()
                me.showHUD(error: $0)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func _uploadAvatar(path: String) -> Observable<String> {
        return EVE.Uploader.shared.upload(.file(path: path))
            .do(onNext: { [uv = _registerView.avatarUploadView] in
                guard case .uploading(let progress) = $0 else { return }
                uv!.progress = Double(progress)
            })
            .map { progress -> String? in
                guard case .finish(let path) = progress else { return nil }
                return path
            }
            .ignoreNil()
    }
}

extension UI where Base: Account.Register.View {
    var invalidatedRightView: UIView {
        let ret = UIImageView(image: R.image.edit()?.withRenderingMode(.alwaysTemplate))
        ret.tintColor = UIColor.red.withAlphaComponent(0.45)
        return ret
    }
    var textFieldValidate: (UITextField, Bool) -> () {
        return { $0.rightView = $1 ? nil : self.invalidatedRightView }
    }
}

final class RegisterView: UIView {
    @IBOutlet weak var avatarUploadView: AvatarUploadView!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var repeatPasswordTF: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var backToLoginBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui.adapt(themeKeyPath: \.mainColor, for: \.backgroundColor)
        
        [phoneTF, nameTF, passwordTF, repeatPasswordTF].forEach { $0?.rightViewMode = .always }
    }
}
