//
//  Chat.Presenter.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/24.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import YYText
import RxSwift
import LayoutKit

extension Chat {
    final class Presenter: NSObject {
        private weak var _chatView: Chat.View?
        
        init(_ chatView: Chat.View) {
            _chatView = chatView
            super.init()
            YYTextKeyboardManager.default()?.add(self)
            _bindNodeEvents()
        }
        
        deinit {
            log()
            YYTextKeyboardManager.default()?.remove(self)
        }
        
        // Keyboard
        typealias KeyboardChangedInfo = (constant: CGFloat, duration: TimeInterval, animationOptions: UIViewAnimationOptions)
        private let _keyboardChangedSubject = PublishSubject<KeyboardChangedInfo>()

        // Node Event
        private let _nodeEventSubject = PublishSubject<NodeEvent>()
        
        // ContentView Refresh
        
        // ContentView Refresh
        private(set) lazy var refreshContentView: Observable<ContentViewRefreshing> = _makeRefresh()
        private let _scrollToBottomSubject = PublishSubject<()>()
    }
}

// MARK: - Open Methods
extension Chat.Presenter {
    func dismissKeyboard() {
        _chatView?.view.endEditing(true)
    }
    
    func scrollToBottom() {
        _scrollToBottomSubject.onNext(())
    }
}

// MARK: - ContentViewRefresh
private extension Chat.Presenter {
    func _makeRefresh() -> Observable<ContentViewRefreshing> {
        let nodes: Observable<ContentViewRefreshing> =  Observable.create { [weak self] subscribe in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guard let layouts = self?.makeTestNode() else { return }
                subscribe.onNext(.nodes(layouts: layouts, batchUpdates: nil))
            }
            return Disposables.create()
        }
        let scroll: Observable<ContentViewRefreshing> = _keyboardChangedSubject.asObserver().map { .scrollWithKeyboard($0) }
        let scrollToBottom: Observable<ContentViewRefreshing> = _scrollToBottomSubject.map { .scrollToBottom }
        return Observable.merge(nodes, scroll, scrollToBottom)
    }
}

// MARK: - NodeEvents
private extension Chat.Presenter {
    func _bindNodeEvents() {
        _nodeEventSubject.subscribeOnMain(onNext: { event in
            print(event)
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - Keyboard Adapter
extension Chat.Presenter: YYTextKeyboardObserver {
    func keyboardChanged(with transition: YYTextKeyboardTransition) {
        let info: KeyboardChangedInfo = (
            transition.toVisible.boolValue ? -transition.toFrame.height : 0,
            transition.animationDuration,
            transition.animationOption
        )
        _keyboardChangedSubject.onNext(info)
    }
    
    func fitKeyboard(for inputViewBottomConstraint: NSLayoutConstraint) {
        _keyboardChangedSubject.subscribeOnMain(onNext: { [weak view = _chatView?.view] info in
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
        }).disposed(by: rx.disposeBag)
    }
}

// MARK: - Events
extension Chat.Presenter {
    enum ContentViewRefreshing {
        case nodes(layouts: [Layout], batchUpdates: BatchUpdates?)
        case scrollWithKeyboard(KeyboardChangedInfo)
        case scrollToBottom
    }
    
    enum NodeEvent {
        case longPress(on: UIView)
    }
}

extension Chat.Presenter {
    func makeTestNode() -> [Layout] {
        let texts = [
            "今天天气不错哦",
            "今天天气不错哦",
            "今天天气不错哦",
            "今天我寒夜里看雪飘过怀着冷却了的心窝票远方，风雨里追赶夜里分不清影踪天空海阔你与我可会边谁没在变",
            "原谅我这一生不羁放纵爱自由",
            "也会怕有一天会跌倒",
            "背弃了理想谁人都可以",
            "也会怕有一天只你共我",
            "今天天气不错哦",
            "今天我寒夜里看雪飘过怀着冷却了的心窝票远方，风雨里追赶夜里分不清影踪天空海阔你与我可会边谁没在变",
            "原谅我这一生不羁放纵爱自由",
            "也会怕有一天会跌倒",
            "背弃了理想谁人都可以",
            "也会怕有一天只你共我",
            "背弃了理想谁人都可以",
            "也会怕有一天只你共我",
            "今天天气不错哦",
            "今天我寒夜里看雪飘过怀着冷却了的心窝票远方，风雨里追赶夜里分不清影踪天空海阔你与我可会边谁没在变",
            "原谅我这一生不羁放纵爱自由",
            "也会怕有一天会跌倒",
            "背弃了理想谁人都可以",
            "也会怕有一天只你共我",
            "今天天气不错哦",
            "今天我寒夜里看雪飘过怀着冷却了的心窝票远方，风雨里追赶夜里分不清影踪天空海阔你与我可会边谁没在变",
            "原谅我这一生不羁放纵爱自由",
            "也会怕有一天会跌倒",
            "背弃了理想谁人都可以",
            "也会怕有一天只你共我",
            "背弃了理想谁人都可以",
            "也会怕有一天只你共我",
            "今天天气不错哦",
            "今天我寒夜里看雪飘过怀着冷却了的心窝票远方，风雨里追赶夜里分不清影踪天空海阔你与我可会边谁没在变",
            "原谅我这一生不羁放纵爱自由",
            ]
        return texts.map(TextLayoutProvider.init).map { Chat.Node(provider: $0, event: _nodeEventSubject) }
    }
}
