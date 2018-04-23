//
//  ImageProcessors.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/23.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import Kingfisher

extension KingfisherOptionsInfoItem {
    static func resizeAndCroppingProcessor(targetSize: CGSize, withCorner radius: CGFloat = 0) -> KingfisherOptionsInfoItem {
        let scale = UIScreen.main.scale
        let resizeSize = CGSize(width: scale * targetSize.width , height: scale * targetSize.height)
        var ret = ResizingImageProcessor(referenceSize: resizeSize, mode: .aspectFill) >> CroppingImageProcessor(size: resizeSize)
        if radius > 0 {
            ret = ret >> RoundCornerImageProcessor(cornerRadius: radius * scale, backgroundColor: .clear)
        }
        return .processor(ret)
    }
    
    static let pngCacheSerializer: KingfisherOptionsInfoItem = .cacheSerializer(FormatIndicatedCacheSerializer.png)
}

extension Array where Element == KingfisherOptionsInfoItem {
    static func normalAvatarOptions(sizeValue: CGFloat) -> [KingfisherOptionsInfoItem] {
        return [
            .transition(.fade(0.25)),
            .resizeAndCroppingProcessor(targetSize: .init(width: sizeValue, height: sizeValue), withCorner: 0.5 * sizeValue),
            .pngCacheSerializer
        ]
    }
}
