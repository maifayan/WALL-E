//
//  Chat.InputView.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/24.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

extension Chat {
    final class InputView: UIViewController {
        private lazy var _contentView: UITextView = {
            let tv = UITextView()
            tv.font = ui.font
            tv.textColor = ui.textColor
            tv.delegate = self
            tv.backgroundColor = .clear
            tv.textContainerInset = .zero
            tv.returnKeyType = .send
            tv.enablesReturnKeyAutomatically = true
            tv.isScrollEnabled = false
            tv.showsVerticalScrollIndicator = false
            return tv
        }()
        
        private lazy var _placeholderLabel: UILabel = {
            let label = UILabel()
            label.isUserInteractionEnabled = false
            label.font = ui.font
            label.text = ui.placeholder
            label.ui.adapt(themeKeyPath: \.mainColor, for: \.textColor) { $0.withAlphaComponent(0.8) }
            return label
        }()
        
        private lazy var _pickImagesButton: UIButton = {
            let button = UIButton(type: .system)
            button.tintColor = .gray
            button.setImage(R.image.chat_images(), for: .normal)
            button.on(.touchUpInside) { _ in print("Pick images") }
            return button
        }()
        
        private var _contentViewHeightConstraint: NSLayoutConstraint?
    }
}

extension Chat.InputView {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(_placeholderLabel)
        view.addSubview(_contentView)
        view.addSubview(_pickImagesButton)
        _layoutViews()
    }
    
    private func _layoutViews() {
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        _pickImagesButton.translatesAutoresizingMaskIntoConstraints = false
        
        _contentView.sizeToFit()
        let initialContentViewHeight = _contentView.height
        
        func fillConstraints(_ aView: UIView) -> [NSLayoutConstraint] {
            let isPlaceholder = aView === _placeholderLabel
            return [
                aView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: ui.topSpacing),
                aView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -ui.bottomSpacing),
                aView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: ui.horizontalSpacing - (isPlaceholder ? -2 : 5)),
                aView.rightAnchor.constraint(equalTo: _pickImagesButton.leftAnchor, constant: -ui.horizontalSpacing + (isPlaceholder ? -2 : 5)),
            ]
        }
        
        let contentViewHeightConstraint = _contentView.heightAnchor.constraint(equalToConstant: initialContentViewHeight)
        _contentViewHeightConstraint = contentViewHeightConstraint
        
        _pickImagesButton.sizeToFit()
        let pickImageButtonBottomSpacing = 0.5 * (initialContentViewHeight + ui.topSpacing + ui.bottomSpacing - _pickImagesButton.height)
        let pickImagesButtonConstraints: [NSLayoutConstraint] = [
            _pickImagesButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -ui.horizontalSpacing),
            _pickImagesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -pickImageButtonBottomSpacing),
            _pickImagesButton.widthAnchor.constraint(equalToConstant: _pickImagesButton.width)
        ]

        NSLayoutConstraint.activate(
            fillConstraints(_contentView) + fillConstraints(_placeholderLabel)
            + [contentViewHeightConstraint]
            + pickImagesButtonConstraints
        )
    }
}

extension Chat.InputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        _contentChanged()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard !text._shouldSend else { _finishInputAndClearText(); return false }
        return true
    }
}

private extension Chat.InputView {
    func _contentChanged() {
        let text = _contentView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        _placeholderLabel.isHidden = !text.isEmpty
        
        // Check: Should re-layout height
        let expectedContentViewHeight = _contentView.sizeThatFits(.init(width: _contentView.width, height: .infinity)).height
        guard
            let contentViewHeightConstraint = _contentViewHeightConstraint,
            contentViewHeightConstraint.constant != expectedContentViewHeight
        else { return }
        contentViewHeightConstraint.constant = expectedContentViewHeight
        UIView.animate(withDuration: 0.25) {
            self.view.superview?.layoutIfNeeded()
        }
    }
    
    func _finishInputAndClearText() {
        _contentView.text = ""
        _contentChanged()
    }
}

extension UI where Base: Chat.InputView {
    var font: UIFont { return .boldSystemFont(ofSize: 17) }
    var textColor: UIColor { return .gray }
    var placeholder: String { return "type something" }
    var horizontalSpacing: CGFloat { return 20 }
    var topSpacing: CGFloat { return 16 }
    var bottomSpacing: CGFloat { return 20 }
}

fileprivate extension String {
    var _shouldSend: Bool { return self == "\n" }
}
