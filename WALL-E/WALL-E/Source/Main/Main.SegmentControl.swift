//
//  Main.SegmentControl.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/22.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import Tactile
import RxCocoa
import RxSwift

extension Main {
    final class SegmentControl: UIViewController {
        private lazy var _leftItem = _Item.make(style: .left)
        private lazy var _rightItem = _Item.make(style: .right)
        
        enum SelectedSide {
            case left
            case right
        }
        
        var selectedSide: SelectedSide = .right {
            didSet {
                guard selectedSide != oldValue else { return }
                let isLeft = selectedSide == .left
                (_leftItem.isSelected, _rightItem.isSelected) = (isLeft, !isLeft)
                _callback(selectedSide)
            }
        }
        
        private let _titles: (left: String, right: String)
        private let _callback: (SelectedSide) -> ()
        
        init(titles: (left: String, right: String), callback: @escaping (SelectedSide) -> ()) {
            _titles = titles
            _callback = callback
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension Main.SegmentControl {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        view.backgroundColor = ui.backgroundColor
        
        _leftItem.setTitle(_titles.left, for: .normal)
        _rightItem.setTitle(_titles.right, for: .normal)
        
        view.addSubview(_leftItem)
        view.addSubview(_rightItem)
        
        _leftItem.on(.touchUpInside) { [weak self] _ in
            self?.selectedSide = .left
        }
        
        _rightItem.on(.touchUpInside) { [weak self] _ in
            self?.selectedSide = .right
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedSide = .left
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        (_leftItem.center.y, _rightItem.center.y) = double(0.5 * view.height)
        _leftItem.x = 0.5 * (view.width - ui.itemSpacing) - _leftItem.ui.width
        _rightItem.x = 0.5 * (view.width + ui.itemSpacing)
    }
}

extension UI where Base: Main.SegmentControl {
    var height: CGFloat { return 60 }
    var backgroundColor: UIColor { return .white }
    var itemSpacing: CGFloat { return 4 }
}

private extension Main.SegmentControl {
    final class _Item: UIButton {
        enum Style {
            case left
            case right
        }
        
        private var _style: Style = .left
        
        static func make(style: Style) -> _Item {
            let ret = _Item(type: .system)
            ret._style = style
            ret.size = ret.ui.size
            ret.layer.addSublayer(ret._backgroundLayer)
            ret.layer.cornerRadius = 3
            ret.autoresizingMask = style == .left ? .flexibleLeftMargin : .flexibleRightMargin
            
            ret.setShadow(color: .gray, offSet: CGSize(width: 0, height: 4), radius: 5, opacity: 0)

            ret.setTitleColor(.white, for: .selected)
            ret.setTitleColor(UIColor(rgb: triple(146)), for: .normal)
            ret.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
            ret._render(isHighlighted: false, withAnimation: false)
            
            ret.rx.observe(Bool.self, #keyPath(_Item.isSelected)).subscribe(onNext: { [weak ret] in
                ret?._render(isHighlighted: $0 ?? false)
            }).disposed(by: ret.rx.disposeBag)
            return ret
        }

        private lazy var _backgroundLayer: CAShapeLayer = {
            let corners: UIRectCorner = _style == .left ? [.topLeft, .bottomLeft] : [.topRight, .bottomRight]
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: ui.size), byRoundingCorners: corners, cornerRadii: CGSize(width: 0.5 * ui.height, height: 0.5 * ui.height))
            let backgroundLayer = CAShapeLayer()
            backgroundLayer.path = path.cgPath
            return backgroundLayer
        }()
    }
}

private extension Main.SegmentControl._Item {
    func _render(isHighlighted: Bool, withAnimation flag: Bool = true) {
        let duration: TimeInterval = flag ? 0.3 : 0
        if isHighlighted {
            UIView.animate(withDuration: duration) {
                self._backgroundLayer.ui.adapt(themeKeyPath: \.mainColor, for: \.fillColor) { $0.cgColor }
                self.transform = CGAffineTransform(translationX: 0, y: -4)
                self.layer.shadowOpacity = self.ui.highlightedShadowOpacity
            }
        } else {
            UIView.animate(withDuration: duration) {
                self._backgroundLayer.ui.cancelAdapt(themeKeyPath: \Theme.mainColor, for: \CAShapeLayer.fillColor)
                self._backgroundLayer.fillColor = self.ui.normalBackgroundColor.cgColor
                self.transform = .identity
                self.layer.shadowOpacity = 0
            }
        }
    }
}

extension UI where Base: Main.SegmentControl._Item {
    var height: CGFloat { return 38 }
    var width: CGFloat { return 136 }
    var size: CGSize { return CGSize(width: width, height: height) }
    var normalBackgroundColor: UIColor { return UIColor(rgb: triple(240)) }
    var highlightedShadowOpacity: Float { return 0.5 }
}
