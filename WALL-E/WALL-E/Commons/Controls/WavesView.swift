//
//  WavesView.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/13.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import WXWaveView

final class WavesView: UIView {
    typealias WaveItem = (color: UIColor, speed: CGFloat, heightRatio: CGFloat)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    private func _setup() {
        let items: [WaveItem] = [
            (UIColor.white.withAlphaComponent(0.7), 1, 0.4),
            (UIColor.white.withAlphaComponent(0.55), 0.72, 0.5),
            (UIColor.white.withAlphaComponent(0.45), 1.4, 0.32),
            (UIColor.white.withAlphaComponent(0.6), 2.5, 0.38),
            (UIColor.white.withAlphaComponent(1), 2, 0.18)
        ]
        _ = items.map(_makeWaveView).map(flip(WXWaveView.wave)())
    }
    
    @discardableResult
    private func _makeWaveView(_ item: WaveItem) -> WXWaveView {
        let view = WXWaveView.add(to: self, withFrame: .zero)!
        view.translatesAutoresizingMaskIntoConstraints = false
        view.waveTime = 0
        view.waveColor = item.color
        view.waveSpeed = item.speed
        view.angularSpeed = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) + 1
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.heightAnchor.constraint(equalTo: heightAnchor, multiplier: item.heightRatio)
        ])
        view.setShadow(color: .gray, offSet: CGSize(width: 2, height: 2), radius: 3, opacity: 0.2)
        return view
    }
}
