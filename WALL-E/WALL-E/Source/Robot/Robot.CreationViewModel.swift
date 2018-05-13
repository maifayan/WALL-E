//
//  Robot.CreationViewModel.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/13.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import EVE
import RxSwift

extension Robot {
    final class CreationViewModel {
        init(context: Context, view: UIViewController, pickAvatar: Observable<()>, name: Observable<String?>, create: Observable<()>) {
            unowned let view = view
            let name = name.map { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }.share(replay: 1)

            guard #available(iOS 11, *) else {
                fatalError("Not support this version!")
            }
            let avatarPickerInfo = pickAvatar.flatMap(const(UIImagePickerController.pick(on: view, config: {
                $0.allowsEditing = false
                $0.sourceType = .photoLibrary
            }))).share(replay: 1)

            let avatarURLStr: Observable<String?> = avatarPickerInfo.map(first).map { $0.path }.startWith(nil)
            
            let info = create.withLatestFrom(Observable.combineLatest(name, avatarURLStr) { (name: $0, avatar: $1) })
                .map {
                    return (
                        Robot.CreationViewModel._validateName($0.name),
                        Robot.CreationViewModel._validateAvatarURLStr($0.avatar)
                    )
                }.share(replay: 1)
            
            let validatedInfo = info.map(compact).ignoreNil().share(replay: 1)

            let upload = validatedInfo
                .do(onNext: { _ in HUD.show() })
                .map(second)
                .map(EVE.Uploader.Resource.file)
                .flatMap(EVE.Uploader.shared.uploadMapper)
                .share(replay: 1)
            
            // Out put
            updateAvatarImage = avatarPickerInfo.map(second)
            
            validate = info.map { forEach($0) { $0 != nil } }
            
            uploadProgress = upload.map { $0.progress }.ignoreNil()
            
            finish = Observable.combineLatest(upload.map { $0.url }.ignoreNil(), validatedInfo) { avatarURL, info in
                let ret = EVERobotCreateInfo()
                ret.iconURL = avatarURL
                ret.name = info.0
                return ret
            }.flatMap(EVE.workMapper(context.request.createRobot))
                .do(onNext: { _ in HUD.dismiss() })
                .map { $0.token }
        }
        
        let updateAvatarImage: Observable<UIImage>
        let validate: Observable<(name: Bool, avatar: Bool)>
        let uploadProgress: Observable<Float>
        let finish: Observable<String>
    }
}

private extension Robot.CreationViewModel {
    static func _validateName(_ name: String?) -> String? {
        guard let name = name else { return nil }
        return name.trimmingCharacters(in: .whitespacesAndNewlines).count > 3 ? name : nil
    }
    
    static func _validateAvatarURLStr(_ str: String?) -> String? {
        return str
    }
}
