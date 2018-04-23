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
            ret = ret >> RoundCornerImageProcessor(cornerRadius: radius * scale)
        }
        return .processor(ret)
    }
}
