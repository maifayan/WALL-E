//
//  Chat.Presenter.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/24.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import YYText

extension Chat {
    final class Presenter: NSObject {
        private weak var _chatView: Chat.View?
        
        init(_ chatView: Chat.View) {
            _chatView = chatView
            super.init()
            YYTextKeyboardManager.default()?.add(self)
        }
        
        deinit {
            YYTextKeyboardManager.default()?.remove(self)
        }
        
        // Keyboard
        typealias InputViewBottomAnchorRefreshingInfo = (constant: CGFloat, duration: TimeInterval, animationOptions: UIViewAnimationOptions)
        private var _refreshInputViewBottomAnchor: ((InputViewBottomAnchorRefreshingInfo) -> ())?
    }
}

// MARK: - Keyboard Adapter
extension Chat.Presenter: YYTextKeyboardObserver {
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        let info: InputViewBottomAnchorRefreshingInfo = (
            transition.toVisible.boolValue ? -transition.toFrame.height : 0,
            transition.animationDuration,
            transition.animationOption
        )
        _refreshInputViewBottomAnchor?(info)
    }
    
    func fitKeyboard(for inputViewBottomConstraint: NSLayoutConstraint) {
        _refreshInputViewBottomAnchor = { [weak view = _chatView?.view] info in
            let finalConstant: CGFloat = {
                if #available(iOS 11, *) {
                    return info.constant == 0 ? 0 : info.constant + (view?.safeAreaInsets.bottom ?? 0)
                } else {
                    return info.constant
                }
            }()
            inputViewBottomConstraint.constant = finalConstant
            UIView.animate(withDuration: info.duration, delay: 0, options: info.animationOptions, animations: {
                view?.layoutIfNeeded()
            })
        }
    }
}
