//
//  Settings.ContentView.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/26.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import Eureka
import RxSwift
import RxCocoa

extension Settings {
    final class ContentView: UIViewController {
        init(context: Context) {
            _model = Model(context: context)
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _formView = _FormView(model: _model)
        private lazy var _avatarView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.isUserInteractionEnabled = true
            imageView.tap { [weak self] _ in self?._model.pickIconAndUpload() }
            imageView.setShadow(color: .gray, offSet: CGSize(width: 3.5, height: 3.5), radius: 6, opacity: 0.45)
            return imageView
        }()

        private let _model: Model
        
        deinit {
            log()
        }
    }
}

extension Settings.ContentView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.setShadow(color: .gray, offSet: CGSize(width: 3.5, height: 3.5), radius: 6, opacity: 0.45)
        add(_formView)
        view.addSubview(_avatarView)
        
        // Can't set zero!!!
        let ratio: (CGFloat) -> (CGPoint) -> CGFloat = { h in {  1 - max(-0.4, min(1, $0.y / h)) } }
        
        _formView.rx.observe(CGPoint.self, #keyPath(_FormView.tableView.contentOffset))
            .ignoreNil().distinctUntilChanged().map(ratio(ui.haderViewHeight * 2))
            .subscribe(onNext: { [avatarView = _avatarView] in
                avatarView.alpha = $0
                avatarView.transform = CGAffineTransform(scaleX: $0, y: $0)
            }).disposed(by: rx.disposeBag)
        
        _formView.tableView.tableHeaderView?.height = ui.haderViewHeight
        
        _formView.view.translatesAutoresizingMaskIntoConstraints = false
        _avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _formView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            _formView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            _formView.view.topAnchor.constraint(equalTo: view.topAnchor),
            _formView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            _avatarView.widthAnchor.constraint(equalToConstant: ui.avatarSizeValue),
            _avatarView.heightAnchor.constraint(equalToConstant: ui.avatarSizeValue),
            _avatarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            _avatarView.topAnchor.constraint(equalTo: view.topAnchor, constant: -40)
        ])
        
        _bindAvatarView()
    }
    
    private func _bindAvatarView() {
        _model.iconVal.subscribeOnMain(onNext: { [weak self] in
            self?._setAvatar($0)
        }).disposed(by: rx.disposeBag)
    }
    
    private func _setAvatar(_ source: Settings.Model.IconType) {
        switch source {
        case .image(let image):
            let avatar = resizeAndCroppingProcessor(
                targetSize: .init(width: ui.avatarSizeValue, height: ui.avatarSizeValue),
                withCorner: 0.5 * ui.avatarSizeValue
            ).process(item: .image(image), options: [])
            _avatarView.image = avatar
        case .url(let string):
            if let url = URL(string: string) {
                _avatarView.kf.setImage(
                    with: url.resize(
                        to: CGSize(width: ui.avatarSizeValue, height: ui.avatarSizeValue)
                    ),
                    options: .normalAvatarOptions(sizeValue: ui.avatarSizeValue)
                )
            }
        case .none: ()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _model.saveAndUpdate()
    }
}

private extension Settings.ContentView {
    final class _FormView: FormViewController {
        private let _model: Settings.Model
        
        init(model: Settings.Model) {
            _model = model
            super.init(style: .grouped)
        }
        
        deinit {
            log()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.backgroundColor = .white
            view.clipsToBounds = true
            view.layer.cornerRadius = 16
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
            tableView.tableHeaderView = UIView()
            tableView.showsVerticalScrollIndicator = false
            
            _setupTheme()
            _setupForm()
        }
    }
}

private extension Settings.ContentView._FormView {
    func _setupTheme() {
        let dark: (UIColor) -> UIColor = { color in
            let magicNum: CGFloat = 20 / 255
            return color.trim {
                $0.red -= magicNum
                $0.green -= magicNum
                $0.blue -= magicNum
            }
        }
        
        func adaptThemeMainColor(_ label: UILabel?) {
            label?.ui.adapt(themeKeyPath: \.mainColor, for: \.textColor) { dark($0) }
        }
        
        NameRow.defaultCellUpdate = { cell, _ in
            adaptThemeMainColor(cell.titleLabel)
            cell.textField.textColor = .gray
        }
        PhoneRow.defaultCellUpdate = { cell, _ in
            adaptThemeMainColor(cell.titleLabel)
            cell.textField.textColor = .gray
        }
        LabelRow.defaultCellUpdate = { cell, _ in
            adaptThemeMainColor(cell.textLabel)
        }
        SwitchRow.defaultCellUpdate = { cell, _ in
            adaptThemeMainColor(cell.textLabel)
        }
        CheckRow.defaultCellUpdate = { cell, _ in
            adaptThemeMainColor(cell.textLabel)
            cell.tintColor = .gray
        }
    }
    
    func _setupForm() {
        let model = _model
        func onChange<T, C: Cell<T>, R: Row<C>, O>(val: BehaviorRelay<O>, filter: ((T) -> Bool)? = nil, mapper: @escaping (T) -> O) -> (R) -> () {
            return { row in
                guard let value = row.value else { return }
                if let filter = filter, !filter(value) { return }
                value |> mapper >>> val.accept
            }
        }

        func subscribe<T, C: Cell<O>, R: Row<C>, O>(row: R, val: BehaviorRelay<T>, mapper: @escaping (T) -> O) {
            let refresh: (T) -> () = { [weak row] in
                let newValue = mapper($0)
                guard row?.value != newValue else { return }
                row?.value = newValue
                row?.updateCell()
            }
            val.subscribeOnMain(onNext: refresh).disposed(by: row.cell.rx.disposeBag)
        }

        form +++ Section("Profile")
            <<< NameRow() { row in
                row.title = "User Name"
                row.onChange(onChange(val: model.nameVal, mapper: id))
                row.cellSetup { subscribe(row: $1, val: model.nameVal, mapper: id)}
            }
            <<< PhoneRow() { row in
                row.title = "Phone"
                row.onChange(onChange(val: model.phoneVal, mapper: id))
                row.cellSetup { subscribe(row: $1, val: model.phoneVal, mapper: id)}
            }
            <<< LabelRow() { row in
                row.title = "Change Password"
            }
        +++ Section("Enter key options")
            <<< CheckRow() { row in
                row.title = "Send"
                row.onChange(
                    merge(
                        onChange(val: model.enterKeyOptionsVal, filter: { $0 == true }, mapper: const(.send)),
                        { $0.cell.isUserInteractionEnabled = $0.value == false }
                    )
                )
                row.cellSetup { subscribe(row: $1, val: model.enterKeyOptionsVal) { $0 == .send } }
            }
            <<< CheckRow() { row in
                row.title = "Newline"
                row.onChange(
                    merge(
                        onChange(val: model.enterKeyOptionsVal, filter: { $0 == true }, mapper: const(.newline)),
                        { $0.cell.isUserInteractionEnabled = $0.value == false }
                    )
                )
                row.cellSetup { subscribe(row: $1, val: model.enterKeyOptionsVal) { $0 == .newline } }
            }
        +++ Section()
            <<< SwitchRow() { row in
                row.title = "Show message date"
                row.onChange(onChange(val: model.showDateVal, mapper: id))
                row.cellSetup { subscribe(row: $1, val: model.showDateVal, mapper: id) }
            }
        +++ Section()
            <<< LabelRow() { row in
                row.title = "Clear Cache(16 KB)"
            }
            <<< LabelRow() { row in
                row.title = "About WALL-E"
            }
            <<< LabelRow() { row in
                row.title = "Sign Out"
                row.onCellSelection { _, _ in model.signOut() }
                row.cellSetup { cell, _ in
                    cell.selectionStyle = .default
                }
            }
    }
}

extension UI where Base: Settings.ContentView {
    var avatarSizeValue: CGFloat { return 130 }
    var haderViewHeight: CGFloat { return 45 }
}
