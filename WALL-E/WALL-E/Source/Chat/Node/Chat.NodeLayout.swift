//
//  Chat.NodeLayout.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/26.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import LayoutKit
import RxSwift

protocol ChatNodeLayoutProvider {
    var isMyOwn: Bool { get }
    var insets: UIEdgeInsets { get }
    func layout(event: PublishSubject<Chat.Presenter.NodeEvent>) -> Layout
}

final class TextLayoutProvider: ChatNodeLayoutProvider {
    private let _msg: Message
    
    init(message: Message) {
        _msg = message
    }
    
    var isMyOwn: Bool {
        return _msg.sender?.id == Context.current?.uid
    }
    
    var insets: UIEdgeInsets {
        return .init(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func layout(event: PublishSubject<Chat.Presenter.NodeEvent>) -> Layout {
        let isMyOwn = self.isMyOwn
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        let attributedString = NSAttributedString(
            string: _msg.content,
            attributes: [
                .paragraphStyle: paragraph,
            ]
        )
        
        var sublayouts: [Layout] = [
            LabelLayout(
                text: .attributed(attributedString),
                font: .boldSystemFont(ofSize: 16),
                viewReuseId: "LabelLayout"
            ) {
                $0.textColor = isMyOwn ? .gray : .white
            },
        ]
        if Settings.showMessageDate {
            sublayouts.append(
                LabelLayout(
                    text: _msg.createdAt.shortTimeString,
                    font: .boldSystemFont(ofSize: 14),
                    numberOfLines: 1,
                    viewReuseId: "TimeLabel"
                ) {
                    $0.textColor = isMyOwn ? .lightGray : UIColor(rgb: triple(235))
                }
            )
        }
        
        return StackLayout(
            axis: .vertical,
            spacing: 8,
            viewReuseId: "TextContentLayout",
            sublayouts: sublayouts
        )
    }
}

final class TypingProvider: ChatNodeLayoutProvider {
    // Always return false
    var isMyOwn: Bool { return false }
    
    var insets: UIEdgeInsets {
        return .init(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func layout(event: PublishSubject<Chat.Presenter.NodeEvent>) -> Layout {
        return SizeLayout<Chat.NodeTypingView>(size: Chat.NodeTypingView.size, viewReuseId: "TypingContentLayout") { _ in }
    }
}
