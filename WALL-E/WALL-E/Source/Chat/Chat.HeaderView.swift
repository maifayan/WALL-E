//
//  Chat.HeaderView.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/24.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

extension Chat {
    final class HeaderView: UIViewController {
        private lazy var _backButton: UIButton = { (dismiss: @escaping () -> ()) in
            let button = UIButton(type: .system)
            button.ui.adapt(themeKeyPath: \.mainColor, for: \.tintColor)
            button.setImage(R.image.chat_back()?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.on(.touchUpInside) { _ in dismiss() }
            return button
        } { [weak self] in self?.dismiss(animated: true, completion: nil) }
        
        private lazy var _avatarView: UIImageView = {
            let imageView = UIImageView()
            let url = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524402344412&di=4a23252a1384630713ed00984077d7aa&imgtype=0&src=http%3A%2F%2Fimg2.ph.126.net%2FiWniabDDa1xwCebyA6-75A%3D%3D%2F6597431505982826060.jpg"
            imageView.kf.setImage(with: URL(string: url), options: .normalAvatarOptions(sizeValue: ui.avatarSizeValue))
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        private lazy var _nickLabel: UILabel = {
            let label = UILabel()
            label.text = "Tangent"
            label.font = .boldSystemFont(ofSize: 20)
            label.numberOfLines = 1
            label.textColor = .gray
            return label
        }()
        
        private lazy var _onlinePoint: UIView = {
            let point = UIView()
            point.backgroundColor = UIColor(r: 120, g: 246, b: 75)
            point.clipsToBounds = true
            point.layer.cornerRadius = 0.5 * ui.onlinePointSizeValue
            return point
        }()
    }
}

extension Chat.HeaderView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(_backButton)
        view.addSubview(_avatarView)
        view.addSubview(_nickLabel)
        view.addSubview(_onlinePoint)
        
        _backButton.translatesAutoresizingMaskIntoConstraints = false
        _avatarView.translatesAutoresizingMaskIntoConstraints = false
        _nickLabel.translatesAutoresizingMaskIntoConstraints = false
        _onlinePoint.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _avatarView.widthAnchor.constraint(equalToConstant: ui.avatarSizeValue),
            _avatarView.heightAnchor.constraint(equalToConstant: ui.avatarSizeValue),
            _avatarView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            _avatarView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: ui.contentHorizontalPadding),
            
            _nickLabel.leftAnchor.constraint(equalTo: _avatarView.rightAnchor, constant: 16),
            _nickLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            _backButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -ui.contentHorizontalPadding),
            _backButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            _onlinePoint.widthAnchor.constraint(equalToConstant: ui.onlinePointSizeValue),
            _onlinePoint.heightAnchor.constraint(equalToConstant: ui.onlinePointSizeValue),
            _onlinePoint.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            _onlinePoint.leftAnchor.constraint(equalTo: _nickLabel.rightAnchor, constant: 8)
        ])
    }
}

extension UI where Base: Chat.HeaderView {
    var contentHorizontalPadding: CGFloat { return 20 }
    var avatarSizeValue: CGFloat { return 48 }
    var onlinePointSizeValue: CGFloat { return 9 }
}
