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
        init(conversation: String) {
            let insets = EdgeInsets(top: 16, left: 30, bottom: 16, right: 30)
            
            let contentVerticalLayout = Item._makeContentVerticalLayout(conversation: conversation)
            super.init(insets: insets, sublayout: contentVerticalLayout)
                { $0.backgroundColor = .clear }
        }
    }
}

private extension Main.Conversations.Item {
    static func _makeProfileHorizontalLayout(conversation: String) -> Layout {
        let avatarLayout = SizeLayout<UIImageView>(
            size: .init(width: avatarSizeValue, height: avatarSizeValue),
            alignment: .centerLeading,
            viewReuseId: "AvatarLayout"
        ) { imageView in
            let url = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1524402344412&di=4a23252a1384630713ed00984077d7aa&imgtype=0&src=http%3A%2F%2Fimg2.ph.126.net%2FiWniabDDa1xwCebyA6-75A%3D%3D%2F6597431505982826060.jpg"
            imageView.kf.setImage(with: URL(string: url), options: .normalAvatarOptions(sizeValue: avatarSizeValue))
            imageView.contentMode = .scaleAspectFill
        }
        
        let nickColor = UIColor(rgb: triple(133))
        let randomColor = arc4random_uniform(2) + 1 == 1 ? nickColor : Theme.shared.mainColor
        let nickLayout = LabelLayout(
            text: "Tangent",
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
            $0.backgroundColor = onlineColor
        }
        
        let timeLayout = LabelLayout(
            text: "3分钟前",
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
    
    static func _makeSummaryLayout(conversation: String) -> Layout {
        let text = "今天我寒夜里看雪飘过怀着冷却了的信我票远方，风雨里追赶梦里分不清影踪天空还附你与我可以变谁没在变原谅我这一生不羁放纵哎自由也会怕有一天会跌倒备齐了理想谁人都可以哪会怕有一个执泥供我"
        return LabelLayout(
            text: text,
            font: .systemFont(ofSize: 13, weight: .bold),
            numberOfLines: 3,
            viewReuseId: "SummaryLayout"
        ) { $0.textColor = UIColor(rgb: triple(119)) }
    }

    static func _makeContentVerticalLayout(conversation: String) -> Layout {
        return StackLayout(
            axis: .vertical,
            spacing: 12,
            viewReuseId: "ContentVerticalLayout",
            sublayouts: [
                _makeProfileHorizontalLayout(conversation: conversation),
                _makeSummaryLayout(conversation: conversation)
            ]
        )
    }
}
