//
//  Settings.View.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/26.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

extension Settings {
    final class View: UIViewController {
        private let _context: Context
        
        init(context: Context) {
            _context = context
            super.init(nibName: nil, bundle: nil)
            modalPresentationStyle = .overCurrentContext
            modalTransitionStyle = .crossDissolve
        }
        
        deinit {
            log()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private lazy var _backgroundView: UIView = {
            let effect = UIBlurEffect(style: .light)
            let view = UIVisualEffectView(effect: effect)
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            return view
        }()
        
        private lazy var _contentView = ContentView(context: _context)
    }
}

extension Settings.View {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(_backgroundView)
        add(_contentView)
        _layoutViews()

        _backgroundView.tap { [weak self] _ in
            self?._saveAndDismiss()
        }
        
        _contentView.view.alpha = 0
        _contentView.view.transform = CGAffineTransform(translationX: 0, y: -60)
    }

    private func _layoutViews() {
        _backgroundView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            _backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
            _backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
            _backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            _backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            _contentView.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: ui.contentViewHorizontalSpaing),
            _contentView.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -ui.contentViewHorizontalSpaing),
            _contentView.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            _contentView.view.heightAnchor.constraint(equalToConstant: ui.contentViewHeight)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _switchTo(show: true)
    }
}

private extension Settings.View {
    func _switchTo(show: Bool) {
        if show && _contentView.view.transform != .identity {
            UIView.animate(withDuration: 0.25) {
                self._contentView.view.transform = .identity
                self._contentView.view.alpha = 1
            }
        } else if !show {
            UIView.animate(withDuration: 0.25, animations: {
                self._contentView.view.transform = CGAffineTransform(translationX: 0, y: 50)
                self._contentView.view.alpha = 0
            }) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func _saveAndDismiss() {
        _switchTo(show: false)
    }
}

extension UI where Base: Settings.View {
    var contentViewHeight: CGFloat { return 0.65 * UIScreen.main.bounds.height }
    var contentViewHorizontalSpaing: CGFloat { return 34 }
}
