//
//  Profile.View.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/23.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import WXWaveView

extension Profile {
    final class View: UIViewController {
        init(contact: String) {
            super.init(nibName: nil, bundle: nil)
            modalTransitionStyle = .crossDissolve
            modalPresentationStyle = .overCurrentContext
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _blurView: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .light)
            let view = UIVisualEffectView(effect: effect)
            return view
        }()
        
        private lazy var _contentView = _ContentView()
    }
    
    enum Event {
        case chat
    }
}

extension Profile.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(_blurView)
        addChildViewController(_contentView)
        view.addSubview(_contentView.view)
        _contentView.view.transform = CGAffineTransform(translationX: 0, y: -60)
        _contentView.didMove(toParentViewController: self)
        _layoutViews()
        
        _blurView.on(UITapGestureRecognizer()) { [weak self] _ in
            self?.switchTo(show: false)
        }
    }
    
    func _layoutViews() {
        _blurView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _blurView.leftAnchor.constraint(equalTo: view.leftAnchor),
            _blurView.rightAnchor.constraint(equalTo: view.rightAnchor),
            _blurView.topAnchor.constraint(equalTo: view.topAnchor),
            _blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            _contentView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            _contentView.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            _contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: ui.contentViewHorizontalPadding),
            _contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -ui.contentViewHorizontalPadding),
            _contentView.view.heightAnchor.constraint(equalToConstant: ui.contentViewHeight)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchTo(show: true)
    }

    func switchTo(show flag: Bool) {
        if flag && _contentView.view.transform != .identity {
            UIView.animate(withDuration: 0.35) {
                self._contentView.view.transform = .identity
            }
        } else if !flag {
            UIView.animate(withDuration: 0.25, animations: {
                self._contentView.view.alpha = 0
                self._contentView.view.transform = CGAffineTransform(translationX: 0, y: 50)
            }) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension UI where Base: Profile.View {
    var contentViewHeight: CGFloat { return 380 }
    var contentViewHorizontalPadding: CGFloat { return 44 }
}

private extension Profile.View {
    final class _ContentView: UIViewController {
        init() {
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _headerView = _HeaderView()
        private lazy var _footerView = _FooterView { [weak self] in
            switch $0 {
            case .chat:
                self?.dismiss(animated: true) { [weak viewController = self?.presentingViewController] in
                    viewController?.present(Chat.View(), animated: true, completion: nil)
                }
            }
        }
    }
}

extension Profile.View._ContentView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.setShadow(color: .gray, offSet: CGSize(width: 3.5, height: 3.5), radius: 6, opacity: 0.45)

        view.addSubview(_headerView)
        view.addSubview(_footerView)
        _layoutViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _headerView.roundCorners([.topLeft, .topRight], radius: ui.cornerRadius)
        _footerView.roundCorners([.bottomLeft, .bottomRight], radius: ui.cornerRadius)
    }
    
    private func _layoutViews() {
        _headerView.translatesAutoresizingMaskIntoConstraints = false
        _footerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            _headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            _headerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            _headerView.topAnchor.constraint(equalTo: view.topAnchor),
            _headerView.bottomAnchor.constraint(equalTo: _footerView.topAnchor, constant: 1),
            
            _footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            _footerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            _footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            _footerView.heightAnchor.constraint(equalToConstant: ui.footerViewHeight)
        ])
    }
}

extension UI where Base: Profile.View._ContentView {
    var cornerRadius: CGFloat { return 22 }
    var footerViewHeight: CGFloat { return 65 }
}

private extension Profile.View._ContentView {
    final class _HeaderView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            ui.adapt(themeKeyPath: \.mainColor, for: \.backgroundColor)
            addSubview(_avatarView)
            addSubview(_nickLabel)
            addSubview(_phoneLabel)
            addSubview(_wavesView)
            _layoutViews()
            clipsToBounds = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _avatarView: UIImageView = {
            let imageView = UIImageView()
            let url = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524402344412&di=4a23252a1384630713ed00984077d7aa&imgtype=0&src=http%3A%2F%2Fimg2.ph.126.net%2FiWniabDDa1xwCebyA6-75A%3D%3D%2F6597431505982826060.jpg"
            imageView.kf.setImage(with: URL(string: url), options: .normalAvatarOptions(sizeValue: ui.avatarSizeValue))
            imageView.contentMode = .scaleAspectFill
            imageView.setShadow(color: .gray, offSet: CGSize(width: 3.5, height: 3.5), radius: 6, opacity: 0.45)
            return imageView
        }()
        
        private lazy var _nickLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 28, weight: .bold)
            label.textAlignment = .center
            label.text = "Tangent"
            label.numberOfLines = 1
            return label
        }()
        
        private lazy var _phoneLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 20, weight: .bold)
            label.textAlignment = .center
            label.text = "18565850472"
            label.numberOfLines = 1
            return label
        }()
        
        private lazy var _wavesView: _WavesView = _WavesView()
        
        private func _layoutViews() {
            _avatarView.translatesAutoresizingMaskIntoConstraints = false
            _wavesView.translatesAutoresizingMaskIntoConstraints = false
            _nickLabel.translatesAutoresizingMaskIntoConstraints = false
            _phoneLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                _avatarView.centerXAnchor.constraint(equalTo: centerXAnchor),
                _avatarView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -ui.wavesViewHeight),
                _avatarView.heightAnchor.constraint(equalToConstant: ui.avatarSizeValue),
                _avatarView.widthAnchor.constraint(equalToConstant: ui.avatarSizeValue),
                
                _nickLabel.leftAnchor.constraint(equalTo: leftAnchor),
                _nickLabel.rightAnchor.constraint(equalTo: rightAnchor),
                _nickLabel.topAnchor.constraint(equalTo: _avatarView.bottomAnchor, constant: 8),
                
                _phoneLabel.leftAnchor.constraint(equalTo: leftAnchor),
                _phoneLabel.rightAnchor.constraint(equalTo: rightAnchor),
                _phoneLabel.topAnchor.constraint(equalTo: _nickLabel.bottomAnchor, constant: 6),
                
                _wavesView.heightAnchor.constraint(equalToConstant: ui.wavesViewHeight),
                _wavesView.bottomAnchor.constraint(equalTo: bottomAnchor),
                _wavesView.leftAnchor.constraint(equalTo: leftAnchor),
                _wavesView.rightAnchor.constraint(equalTo: rightAnchor)
            ])
        }
        
        private final class _WavesView: UIView {
            typealias WaveItem = (color: UIColor, speed: CGFloat, height: CGFloat)
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                let items: [WaveItem] = [
                    (UIColor.white.withAlphaComponent(0.7), 1, 20),
                    (UIColor.white.withAlphaComponent(0.55), 0.72, 29),
                    (UIColor.white.withAlphaComponent(0.45), 1.4, 26),
                    (UIColor.white.withAlphaComponent(0.6), 2.5, 19),
                    (UIColor.white.withAlphaComponent(1), 2, 9)
                ]
                _ = items.map(_makeWaveView).map(flip(WXWaveView.wave)())
            }
            
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            @discardableResult
            private func _makeWaveView(_ item: WaveItem) -> WXWaveView {
                let view = WXWaveView.add(to: self, withFrame: .zero)!
                view.translatesAutoresizingMaskIntoConstraints = false
                view.waveTime = 0
                view.waveColor = item.color
                view.waveSpeed = item.speed
                view.angularSpeed = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + 1
                NSLayoutConstraint.activate([
                    view.leftAnchor.constraint(equalTo: leftAnchor),
                    view.rightAnchor.constraint(equalTo: rightAnchor),
                    view.bottomAnchor.constraint(equalTo: bottomAnchor),
                    view.heightAnchor.constraint(equalToConstant: item.height)
                ])
                view.setShadow(color: .gray, offSet: CGSize(width: 2, height: 2), radius: 3, opacity: 0.2)
                return view
            }
        }
    }
    
    final class _FooterView: UIView {
        init(eventsCallback: @escaping (Profile.Event) -> ()) {
            super.init(frame: .zero)
            backgroundColor = .white
            addSubview(_chatButton)
            _chatButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                _chatButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                _chatButton.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            _chatButton.on(.touchUpInside, const(eventsCallback(.chat)))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            _chatButton.layout(with: .vImageLabel, space: 6)
        }
        
        private lazy var _chatButton: UIButton = {
            let button = UIButton(type: .system)
            button.ui.adapt(themeKeyPath: \.mainColor, for: \.tintColor)
            button.titleLabel?.font = .boldSystemFont(ofSize: 13)
            button.setTitle("Chat", for: .normal)
            button.setImage(R.image.chat()?.withRenderingMode(.alwaysTemplate), for: .normal)
            return button
        }()
    }
}

extension UI where Base: Profile.View._ContentView._HeaderView {
    var avatarSizeValue: CGFloat { return 150 }
    var wavesViewHeight: CGFloat { return 50 }
}
