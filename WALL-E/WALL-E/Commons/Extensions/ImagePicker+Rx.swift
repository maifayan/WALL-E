//
//  ImagePicker+Rx.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/7.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit
import MessageListener
import RxSwift

private var imagePickerDelegateKey: UInt8 = 23
extension UIImagePickerController {
    static func pick(on viewController: UIViewController, config: ((UIImagePickerController) -> ())? = nil) -> Observable<[String: Any]> {
        let picker = UIImagePickerController()
        config?(picker)
        let delegate = _Delegate()
        objc_setAssociatedObject(picker, &imagePickerDelegateKey, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        defer { picker.delegate = delegate }
        viewController.present(picker, animated: true, completion: nil)

        let selector = #selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:))
        return delegate.rx.listen(selector, in: UIImagePickerControllerDelegate.self)
            .do(onNext: { [weak picker] _ in picker?.dismiss(animated: true, completion: nil) })
            .map { $0[1] as! [String: Any] }
    }
    
    private final class _Delegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate { }
}