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
    private let _text: String
    
    init(text: String) {
        _text = text
    }
    
    var isMyOwn: Bool {
        return _text.count % 2 == 0
    }
    
    var insets: UIEdgeInsets {
        return .init(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func layout(event: PublishSubject<Chat.Presenter.NodeEvent>) -> Layout {
        let isMyOwn = self.isMyOwn
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        let attributedString = NSAttributedString(
            string: _text,
            attributes: [
                .paragraphStyle: paragraph,
                ]
        )
        
        return StackLayout(
            axis: .vertical,
            spacing: 8,
            viewReuseId: "TextContentLayout",
            sublayouts: [
                LabelLayout(
                    text: .attributed(attributedString),
                    font: .boldSystemFont(ofSize: 16),
                    viewReuseId: "LabelLayout"
                ) {
                    $0.textColor = isMyOwn ? .gray : .white
                },
                
                LabelLayout(
                    text: "19:32",
                    font: .boldSystemFont(ofSize: 14),
                    numberOfLines: 1,
                    viewReuseId: "TimeLabel"
                ) {
                    $0.textColor = isMyOwn ? .lightGray : UIColor(rgb: triple(235))
                }
            ]
        )
    }
}
