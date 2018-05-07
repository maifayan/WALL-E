//
//  Account.Register.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

extension Account.Register {
    final class View: UIViewController {
        private var _registerView: RegisterView { return view as! RegisterView }
        
        override func loadView() {
            view = R.nib.registerView().instantiate(withOwner: nil, options: nil).first as! UIView
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
        
        _registerView.avatarUploadView.onTap
            .flatMap(const(UIImagePickerController.pick(on: self) {
                $0.allowsEditing = false
                $0.sourceType = .photoLibrary
            }))
            .map {
               $0[UIImagePickerControllerOriginalImage] as? UIImage
            }
            .bind(to: _registerView.avatarUploadView.imageObserver)
            .disposed(by: rx.disposeBag)
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
    }
}
