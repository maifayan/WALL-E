//
//  UIView.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/25.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

extension UIView {
    func setShadow(color: UIColor, offSet: CGSize, radius: CGFloat, opacity: Float) {
        layer.shadowRadius = radius
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
    }
}

extension UIView {
    class SerialAnimation {
        private let _duration: TimeInterval
        private let _delay: TimeInterval
        private let _options: UIViewAnimationOptions
        private let _animations: () -> ()
        
        private var _preAnimation: SerialAnimation?
        private var _completion: (() -> ())?

        init(duration: TimeInterval, delay: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, animations: @escaping () -> ()) {
            _duration = duration
            _delay = delay
            _options = options
            _animations = animations
        }
        
        func next(duration: TimeInterval, delay: TimeInterval = 0, options: UIViewAnimationOptions = .curveEaseInOut, animations: @escaping () -> ()) -> SerialAnimation {
            let animation = SerialAnimation(duration: duration, delay: delay, options: options, animations: animations)
            animation._preAnimation = self
            // 在这里不使用弱引用animation，原因：
            // 为了保持链式引用： A <- B <- C <- D
            // D维持着上面所有对象的上面周期，因为有 _preAnimation 引用
            
            // 若不长维持着D的生命，只是在某个时机调用D的start，D会在动画完成前销毁
            // 所以需要这个闭包持有下一个Animation
            // 为了避免循环引用，在Animtion执行完动画后通知下一个去进行动画，会让下一个放弃对上一个的引用
            _completion = {
                animation._animate()
                animation._preAnimation = nil
            }
            return animation
        }
        
        private func _animate() {
            UIView.animate(withDuration: _duration, delay: _delay, options: _options, animations: _animations) { _ in self._completion?() }
        }
        
        func start() {
            if let pre = _preAnimation {
                pre.start()
            } else {
                _animate()
            }
        }
    }
}
