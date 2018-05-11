//
//  Main.Conversations.Item.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/23.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import LayoutKit
import Kingfisher

private let avatarSizeValue = CGFloat(50)

extension Main.Conversations {
    final class Item: InsetLayout<UIView> {
        init(message: Message) {
            let insets = EdgeInsets(top: 16, left: 30, bottom: 16, right: 30)
            
            let contentVerticalLayout = Item._makeContentVerticalLayout(message: message)
            super.init(insets: insets, sublayout: contentVerticalLayout)
                { $0.backgroundColor = .clear }
        }
    }
}

private extension Main.Conversations.Item {
    static func _makeProfileHorizontalLayout(message: Message) -> Layout {
        let avatarLayout = SizeLayout<AvatarView>(
            size: .init(width: avatarSizeValue, height: avatarSizeValue),
            alignment: .centerLeading,
            viewReuseId: "AvatarLayout"
        ) {
            guard let contact = message.other else { return }
            $0.set(contact, sizeValue: avatarSizeValue, showOnlineState: false)
        }
        
        // TODO: 未读消息名字显示颜色
        let nickColor = UIColor(rgb: triple(133))
        let randomColor = arc4random_uniform(2) + 1 == 1 ? nickColor : Theme.shared.mainColor
        let nickLayout = LabelLayout(
            text: message.other?.name ?? "",
            font: .systemFont(ofSize: 15, weight: .bold),
            numberOfLines: 1,
            alignment: .centerLeading,
            viewReuseId: "NickLayout"
        ) { $0.textColor = randomColor }
        
        let onlineColor = UIColor(r: 120, g: 246, b: 75)
        let onlinePointSizeValue: CGFloat = 9
        let onlinePointLayout = SizeLayout(
            size: .init(width: onlinePointSizeValue, height: onlinePointSizeValue),
            alignment: .centerLeading,
            viewReuseId: "OnlinePoint"
        ) {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 0.5 * onlinePointSizeValue
            $0.backgroundColor = (message.other?.isOnline ?? false) ? onlineColor : .gray
        }
        
        let timeLayout = LabelLayout(
            text: message.createdAt.shortString,
            font: .systemFont(ofSize: 12),
            numberOfLines: 1,
            alignment: .centerTrailing,
            flexibility: .high,
            viewReuseId: "TimeLayout"
        ) { $0.textColor = UIColor(rgb: triple(178)) }

        return StackLayout(
            axis: .horizontal,
            spacing: 12,
            viewReuseId: "ProfileHorizontalLayout",
            sublayouts: [
                avatarLayout,
                nickLayout,
                onlinePointLayout,
                timeLayout
            ]
        )
    }
    
    static func _makeSummaryLayout(message: Message) -> Layout {
        return LabelLayout(
            text: message.content,
            font: .systemFont(ofSize: 16, weight: .bold),
            numberOfLines: 3,
            viewReuseId: "SummaryLayout"
        ) { $0.textColor = UIColor(rgb: triple(119)) }
    }

    static func _makeContentVerticalLayout(message: Message) -> Layout {
        return StackLayout(
            axis: .vertical,
            spacing: 12,
            viewReuseId: "ContentVerticalLayout",
            sublayouts: [
                _makeProfileHorizontalLayout(message: message),
                _makeSummaryLayout(message: message)
            ]
        )
    }
}
