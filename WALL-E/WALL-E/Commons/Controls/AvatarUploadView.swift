//
//  AvatarUploadView.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/7.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import RxSwift
import Photos
import RxCocoa
import KYCircularProgress
import TanImagePicker

private let progressLineWidth: CGFloat = 6
private let placeholderImageSize = CGSize(width: 80, height: 80)
class AvatarUploadView: UIView {
    private let _imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.robot()?.resize(size: placeholderImageSize)
        let image = R.image.robot()
        imageView.contentMode = .center
        return imageView
    }()
    
    private let _progress: KYCircularProgress = {
        let progress = KYCircularProgress(frame: .zero, showGuide: true)
        progress.guideColor = UIColor.white.withAlphaComponent(0.25)
        progress.lineCap = kCALineCapRound
        progress.lineWidth = Double(progressLineWidth)
        progress.guideLineWidth = Double(progressLineWidth)
        progress.startAngle = -0.5 * .pi
        progress.endAngle = 1.5 * .pi
        progress.colors = [.white]
        progress.isUserInteractionEnabled = false
        return progress
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setupViews()
    }
    
    private func _setupViews() {
        addSubview(_imageView)
        addSubview(_progress)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _progress.size = CGSize(width: width + 6, height: height + 6)
        _progress.center = CGPoint(x: 0.5 * width - 1.5, y: 0.5 * height - 1.5)
        _imageView.size = CGSize(width: width - 2 * progressLineWidth, height: height - 2 * progressLineWidth)
        _imageView.center = CGPoint(x: 0.5 * width, y: 0.5 * height)
    }
    
    var isOK: Bool = true {
        didSet {
            _progress.guideColor = isOK ? UIColor.white.withAlphaComponent(0.25) : UIColor.red.withAlphaComponent(0.45)
        }
    }
    
    func setupFlagColor(_ color: UIColor) {
        _progress.guideColor = color
        _progress.colors = [color]
    }

    var image: UIImage? {
        didSet {
            guard let image = image else {
                _imageView.image = R.image.robot()?.resize(size: placeholderImageSize)
                return
            }
            let processor = resizeAndCroppingProcessor(targetSize: _imageView.size, withCorner: 0.5 * _imageView.size.width)
            _imageView.image = processor.process(item: .image(image), options: [.scaleFactor(UIScreen.main.scale)])
        }
    }
    
    var imageObserver: AnyObserver<UIImage> {
        return Binder(self) { view, image in
            view.image = image.resize(size: view._imageView.size)
        }.asObserver()
    }
    
    var progress: Double = 0 {
        didSet {
            _progress.progress = progress
        }
    }
    
    var progressObserver: AnyObserver<Double> {
        return Binder(self) { view, progress in
            view.progress = progress
        }.asObserver()
    }

    var onTap: Observable<()> {
        return Observable.create { [weak self] subscribe in
            self?.tap { _ in subscribe.onNext(()) }
            return Disposables.create()
        }
    }
}
