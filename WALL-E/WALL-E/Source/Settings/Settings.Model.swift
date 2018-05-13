//
//  Settings.Model.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/27.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Settings {
    final class Model {
        typealias Val<T> = BehaviorRelay<T>
        private let _context: Context

        init(context: Context) {
            _context = context
            _loadSettings(context: context)
        }
        
        let iconVal = Val(value: IconType.none)
        let nameVal = Val(value: "")
        let phoneVal = Val(value: "")
        let enterKeyOptionsVal = Val<EnterKeyOptions>(value: .send)
        let showDateVal = Val(value: false)
        
        deinit {
            log()
        }
        
        private let _bag = DisposeBag()
    }
}

extension Settings.Model {
    enum IconType {
        case image(UIImage)
        case url(string: String)
        case none
    }
}

extension Settings.Model {
    func saveAndUpdate() {
        // TODO: Validate
        func notEqualOrNil<T: Equatable>(_ value: T?) -> (T) -> T? {
            return { value == $0 ? nil : $0 }
        }
        let iconStr: Observable<String> = iconVal.map { if case .url(let str) = $0 { return str } else { return nil } }.ignoreNil()
        Observable.combineLatest(
            nameVal.map(notEqualOrNil(_context.me.name)),
            phoneVal.map(notEqualOrNil(_context.me.phone)),
            iconStr.map(notEqualOrNil(_context.me.iconURL))
        ) { (name: $0, phone: $1, icon: $2) }
        .subscribe(onNext: { [weak self] in
            self?._context.request.updateMemberIfNeeds(iconURL: $0.icon, name: $0.name, phone: $0.phone)
        }).disposed(by: _bag)
    }
    
    func pickIconAndUpload() {
        guard #available(iOS 11, *) else {
            log("Version not support")
            return
        }
        guard let vc = UIViewController.topMost else { return }
        let pickImage = UIImagePickerController.pick(on: vc) {
            $0.allowsEditing = false
            $0.sourceType = .photoLibrary
        }.share(replay: 1)

        pickImage.map(second).map(IconType.image).bind(to: iconVal).disposed(by: _bag)
        
        pickImage.map(first).map { $0.path }.map(EVE.Uploader.Resource.file)
            .do(onNext: { _ in HUD.show() })
            .flatMap(EVE.Uploader.shared.uploadMapper)
            .map { $0.url }
            .ignoreNil()
            .map { IconType.url(string: $0) }
            .do(onNext: { _ in HUD.dismiss() })
            .bind(to: iconVal)
            .disposed(by: _bag)
    }
    
    func signOut() {
        let signOut: () -> () = {
            UIViewController.topMost?.dismiss(animated: false) {
                Context.clearAccountInfo()
                (UIApplication.shared.delegate as? AppDelegate)?.setupViewControllers()
            }
        }
        UIViewController.topMost?.showChooseAlert(title: "Sign Out", message: "Sure you want to sign out?", yesAction: signOut)
    }
}

private extension Settings.Model {
    func _loadSettings(context: Context) {
        enterKeyOptionsVal.accept(Settings.enterKeyOptions)
        showDateVal.accept(Settings.showMessageDate)
        
        enterKeyOptionsVal.subscribe(onNext: { Settings.enterKeyOptions = $0 }).disposed(by: _bag)
        showDateVal.subscribe(onNext: { Settings.showMessageDate = $0 }).disposed(by: _bag)
        
        iconVal.accept(.url(string: context.me.iconURL))
        nameVal.accept(context.me.name)
        phoneVal.accept(context.me.phone ?? "")
    }
}
