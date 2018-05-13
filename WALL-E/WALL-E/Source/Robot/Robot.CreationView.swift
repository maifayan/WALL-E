//
//  Robot.CreationView.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/12.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Robot {
    final class CreationView: UIViewController {
        private let _context: Context
        
        init(context: Context) {
            _context = context
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .custom
            modalTransitionStyle = .crossDissolve
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _maskView: UIVisualEffectView = {
            let blur = UIBlurEffect(style: .light)
            let view = UIVisualEffectView(effect: blur)
            return view
        }()
        
        private lazy var _contentView = _ContentView()
        
        private lazy var _viewModel = CreationViewModel(
            context: _context,
            view: self,
            pickAvatar: _contentView.pickAvatar,
            name: _contentView.name,
            create: _contentView.create
        )
    }
}

extension Robot.CreationView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(_maskView)
        add(_contentView)
        _setupViews()
        _contentView.view.transform = CGAffineTransform(translationX: 0, y: -55)
        _contentView.view.alpha = 0
        _bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _layoutViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _switchTo(show: true)
    }

    private func _setupViews() {
        _maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _contentView.view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
        
        _contentView.view.setShadow(color: .gray, offSet: CGSize(width: 3.5, height: 3.5), radius: 6, opacity: 0.45)
        _maskView.tap { [weak self] _ in
            self?._dismiss()
        }
    }
    
    private func _switchTo(show flag: Bool) {
        if flag && _contentView.view.transform != .identity {
            UIView.animate(withDuration: 0.35) {
                self._contentView.view.alpha = 1
                self._contentView.view.transform = .identity
            }
        } else if !flag {
            UIView.animate(withDuration: 0.25, animations: {
                self._contentView.view.transform = CGAffineTransform(translationX: 0, y: 55)
                self._contentView.view.alpha = 0
            }) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func _dismiss() {
        _switchTo(show: false)
    }
    
    private func _layoutViews() {
        _maskView.frame = view.bounds
        _contentView.view.height = ui.contentViewHeight
        _contentView.view.width = view.width - 2 * ui.contentViewHorizontalSpacing
        _contentView.view.center = CGPoint(x: 0.5 * view.width, y: 0.5 * view.height)
    }
    
    private func _bind() {
        _viewModel.validate.subscribeOnMain(_contentView.validate).disposed(by: rx.disposeBag)
        _viewModel.updateAvatarImage.subscribeOnMain(_contentView.avatarImage).disposed(by: rx.disposeBag)
        _viewModel.uploadProgress.map(Double.init).subscribeOnMain(_contentView.avatarUploadProgress).disposed(by: rx.disposeBag)
        _viewModel.finish.subscribeOnMain(onNext: { [weak self] in
            self?._contentView.finish()
            self?._contentView.setupTokenStringForCopy($0)
        }).disposed(by: rx.disposeBag)
    }
}

extension Robot.CreationView {
    final class _ContentView: UIViewController {
        private lazy var _contentView = R.nib.robotCreationContentView().instantiate(withOwner: nil, options: nil).first as! RobotCreationContentView
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .clear
            _contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(_contentView)
            view.adaptToKeyboard(minSpacingToKeyboard: 25)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            _contentView.roundCorners(.allCorners, radius: 16)
            _contentView.frame = view.bounds
        }
        
        var pickAvatar: Observable<()> {
            return _contentView.avatarUploadView.onTap
        }
        
        var name: Observable<String?> {
            return _contentView.nameTF.rx.text.asObservable()
        }
        
        var create: Observable<()> {
            return _contentView.createBtn.rx.tap.asObservable().filter { [weak self] _ in
                self?._isFinished == false
            }
        }
        
        var validate: Binder<(name: Bool, avatar: Bool)> {
            return Binder(self) { me, validate in
                me._contentView.avatarUploadView.isOK = validate.avatar
                me._contentView.nameTF.rightView = validate.name ? nil : {
                    let ret = UIImageView(image: R.image.edit()?.withRenderingMode(.alwaysTemplate))
                    ret.tintColor = UIColor.red.withAlphaComponent(0.45)
                    return ret
                }()
            }
        }
        
        var avatarImage: AnyObserver<UIImage> {
            return _contentView.avatarUploadView.imageObserver
        }
        
        var avatarUploadProgress: AnyObserver<Double> {
            return _contentView.avatarUploadView.progressObserver
        }
        
        func finish() {
            guard !_isFinished else { return }
            _contentView.avatarUploadView.isUserInteractionEnabled = false
            _contentView.avatarUploadView.setupFlagColor(UIColor(r: 120, g: 246, b: 75))
            _contentView.nameTF.isUserInteractionEnabled = false
            _contentView.createBtn.setTitle("Copy Token", for: .normal)
            _isFinished = true
        }
        
        func setupTokenStringForCopy(_ token: String) {
            guard _isFinished else { return }
            _contentView.createBtn.on(.touchUpInside) { _ in
                UIPasteboard.general.string = token
                UIViewController.topMost?.showAlert(message: "Now that you've copied the text, start creating your robot.")
            }
        }
        
        private var _isFinished = false
    }
}

extension UI where Base: Robot.CreationView {
    var contentViewHorizontalSpacing: CGFloat {
        return 35
    }
    
    var contentViewHeight: CGFloat {
        return 340
    }
}

final class RobotCreationContentView: UIView {
    @IBOutlet weak var avatarUploadView: AvatarUploadView!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var createBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui.adapt(themeKeyPath: \.mainColor, for: \.backgroundColor)
        createBtn.setTitleColor(Theme.shared.mainColor, for: .normal)
        nameTF.rightViewMode = .always
        // isa-swizzling
        object_setClass(nameTF, _NameTextField.self)
    }
}

private extension RobotCreationContentView {
    final class _NameTextField: UITextField {
        override func drawPlaceholder(in rect: CGRect) {
            guard let ph = placeholder as NSString? else { return }
            let ps = NSMutableParagraphStyle()
            ps.alignment = .center
            ph.draw(in: rect, withAttributes: [
                .font: font!,
                .foregroundColor: UIColor.white.withAlphaComponent(0.8),
                .paragraphStyle: ps
            ])
        }
    }
}
