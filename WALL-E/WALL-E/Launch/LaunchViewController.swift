//
//  LaunchViewController.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/25.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

final class LaunchViewController: UIViewController {
    static func obtainInstance(finish: @escaping () -> ()) -> UIViewController {
        let ret = R.nib.launchViewController().instantiate(withOwner: nil, options: nil).first as! LaunchViewController
        ret._finish = finish
        return ret
    }
    
    @IBOutlet weak var imageView: UIImageView!
    private var _finish: (() -> ())?
    
    private lazy var _maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = _pathOne
        return layer
    }()
    
    private lazy var _pathOne: CGPath = {
        let initialSizeValue: CGFloat = 85
        return _createPath(sizeValue: initialSizeValue)
    }()
    
    private lazy var _pathTwo: CGPath = {
        let sizeValue = imageView.width / sin(0.25 * .pi)
        return _createPath(sizeValue: sizeValue)
    }()
    
    private func _createPath(sizeValue: CGFloat) -> CGPath {
        let frame = CGRect(x: 0.5 * (imageView.width - sizeValue), y: 0.5 * (imageView.height - sizeValue) - 5,
                           width: sizeValue, height: sizeValue)
        return UIBezierPath(ovalIn: frame).cgPath
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.mask = _maskLayer
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { self._finish?() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
            self.imageView.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let animation = CABasicAnimation(keyPath: "path")
                animation.toValue = self._pathTwo
                animation.duration = 1
                animation.fillMode = kCAFillModeForwards
                animation.isRemovedOnCompletion = false
                self._maskLayer.add(animation, forKey: "animatePath")
            }
        }
    }
}
