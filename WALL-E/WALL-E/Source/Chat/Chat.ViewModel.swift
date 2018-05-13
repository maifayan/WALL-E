//
//  Chat.ViewModel.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/11.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RxSwift
import Photos
import RealmSwift

extension Chat {
    final class ViewModel {
        private let _context: Context
        private let _contact: Contact
        private let _bag = DisposeBag()
        private var _token: NotificationToken?

        private(set) lazy var messages = _context.auto.main.objects(Message.self).filter(Message.predicateForContact(_contact))
        
        init(context: Context, contact: Contact) {
            _context = context
            _contact = contact
            
            _setupShowTyping()
        }
        
        deinit {
            _token?.invalidate()
            _deleteTypingMessage()
        }
        
        private(set) lazy var change: Observable<RealmCollectionChange<Results<Message>>> = {
            return Observable.create { [weak self] subscribe in
                let token = self?.messages.observe {
                    subscribe.onNext($0)
                }
                self?._token = token
                return Disposables.create()
            }
        }()
        
        // Status
        private var _didSendTyping = false
        private var _didShowTyping = false
        private var _dismissTypingWI: DispatchWorkItem?
    }
}

extension Chat.ViewModel {
    func send(_ text: String) {
        _context.connecter.send(.message(to: _contact, content: text))
    }
    
    func send(_ assets: [PHAsset]) {
        assets.forEach(_uploadAndSendImageMessage)
    }
    
    func typing() {
        guard !_didSendTyping else { return }
        after(1.5) { [weak self] in self?._didSendTyping = false }
        _context.connecter.send(.typing(to: _contact))
        _didSendTyping = true
    }
}

private extension Chat.ViewModel {
    func _setupShowTyping() {
        _context.typingObservable.filter { [weak self] in self?._contact.id == $0 }.subscribeOnMain(onNext: { [weak self] _ in
            self?._switchToShowTyping()
        }).disposed(by: _bag)
        
        _context.messageObservable.do(onNext: { [weak self] _ in self?._context.auto.main.refresh() })
            .map { [weak self] in self?._context.auto.main.object(ofType: Message.self, forPrimaryKey: $0) }
            .filter { [weak self] in $0?.sender?.id == self?._contact.id }
            .subscribeOnMain(onNext: { [weak self] _ in
                self?._dismissTypingWI?.perform()
                self?._dismissTypingWI = nil
            })
            .disposed(by: _bag)
    }
    
    func _switchToShowTyping() {
        _dismissTypingWI?.cancel()
        let wi = DispatchWorkItem { [weak self] in
            self?._insertOrDeleteTypingMessage(false)
            self?._didShowTyping = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: wi)
        _dismissTypingWI = wi
        
        guard !_didShowTyping else { return }
        _insertOrDeleteTypingMessage(true)
        _didShowTyping = true
    }
    
    func _insertOrDeleteTypingMessage(_ flag: Bool) {
        if flag {
            _createTypingMessage()
        } else {
            _deleteTypingMessage()
        }
    }
}

private extension Chat.ViewModel {
    func _createTypingMessage() {
        let msg = Message(
            id: NSUUID().uuidString,
            conversationId: _contact.id,
            sender: _contact,
            receiver: _context.me,
            content: "\(_contact.name) is typing...",
            createdAt: .init(),
            updatedAt: .init(),
            type: .typing
        )
        do {
            try _context.auto.writeInMain { $0.add(msg) }
        } catch {
            log(error)
        }
    }
    
    func _deleteTypingMessage() {
        do {
            try _context.auto.writeInMain { realm in
                realm.delete(
                   realm.objects(Message.self)
                        .filter("typeValue == %@ AND sender.id == %@", Message.MessageType.typing.rawValue, _contact.id)
                )
            }
        } catch {
            log(error)
        }
    }
    
    func _uploadAndSendImageMessage(_ asset: PHAsset) {
        return Observable.just(EVE.Uploader.Resource.asset(asset))
            .flatMap(EVE.Uploader.shared.uploadMapper)
            .map { $0.url }
            .ignoreNil()
            .subscribeOnMain(onNext: { [con = _contact, ctx = _context] in
                ctx.connecter.send(.image(to: con, url: $0))
            }, onError: { log($0) })
            .disposed(by: _bag)
    }
}
