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
        private lazy var _formView = _FormView(style: .grouped)
        private lazy var _avatarView: UIImageView = {
            let imageView = UIImageView()
            let url = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524402344412&di=4a23252a1384630713ed00984077d7aa&imgtype=0&src=http%3A%2F%2Fimg2.ph.126.net%2FiWniabDDa1xwCebyA6-75A%3D%3D%2F6597431505982826060.jpg"
            imageView.kf.setImage(with: URL(string: url), options: .normalAvatarOptions(sizeValue: ui.avatarSizeValue))
            imageView.contentMode = .scaleAspectFill
            imageView.setShadow(color: .gray, offSet: CGSize(width: 3.5, height: 3.5), radius: 6, opacity: 0.45)
            return imageView
        }()
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
    }
}

private extension Settings.ContentView {
    final class _FormView: FormViewController {
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
            _setupForm()
        }
    }
}

private extension Settings.ContentView._FormView {
    func _setupForm() {
        let dark: (UIColor) -> UIColor = { color in
            var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            let magicNum: CGFloat = 20 / 255
            return UIColor(red: r - magicNum, green: g - magicNum, blue: b - magicNum, alpha: a)
        }
        
        NameRow.defaultCellUpdate = { cell, _ in
            cell.titleLabel?.ui.adapt(themeKeyPath: \.mainColor, for: \.textColor) { dark($0) }
            cell.textField.textColor = .gray
        }
        PhoneRow.defaultCellUpdate = { cell, _ in
            cell.titleLabel?.ui.adapt(themeKeyPath: \.mainColor, for: \.textColor) { dark($0) }
            cell.textField.textColor = .gray
        }
        LabelRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.ui.adapt(themeKeyPath: \.mainColor, for: \.textColor) { dark($0) }
        }
        CheckRow.defaultCellUpdate = { cell, _ in
            cell.textLabel?.ui.adapt(themeKeyPath: \.mainColor, for: \.textColor) { dark($0) }
            cell.tintColor = .gray
        }

        form +++ Section("Profile")
            <<< NameRow() { row in
                row.title = "User Name"
                row.value = "Tangent"
            }
            <<< PhoneRow() { row in
                row.title = "Phone"
                row.value = "18565850472"
            }
            <<< LabelRow() { row in
                row.title = "Change Password"
            }
        +++ Section("Enter key options")
            <<< CheckRow() { row in
                row.title = "Send"
            }
            <<< CheckRow() { row in
                row.title = "Newline"
                row.value = true
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
            }
    }
}

extension UI where Base: Settings.ContentView {
    var avatarSizeValue: CGFloat { return 130 }
    var haderViewHeight: CGFloat { return 45 }
}
