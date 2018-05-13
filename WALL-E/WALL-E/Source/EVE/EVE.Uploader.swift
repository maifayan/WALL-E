//
//  EVE.Uploader.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/7.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import EVE
import RxSwift
import Qiniu
import Photos

extension EVE {
    final class Uploader {
        static let shared = Uploader()
        
        private let _uploadService = EVEUpload(host: EVE.Config.address)
        private let _manager = QNUploadManager(configuration: Config.managerConfig)!
        private let _lock = NSRecursiveLock()

        private(set) lazy var uploadToken = WorkItem(_uploadService.rpcToFetchToken, .default)
    }
}

extension EVE.Uploader {
    enum Progress {
        case uploading(progress: Float)
        case finish(url: String)
        
        var progress: Float? {
            guard case .uploading(let ret) = self else { return nil }
            return ret
        }
        
        var url: String? {
            guard case .finish(let ret) = self else { return nil }
            return ret
        }
    }
    
    enum Resource {
        case file(path: String)
        case asset(PHAsset)
        case assetResource(PHAssetResource)
        case data(Data)
    }
}

extension EVE.Uploader {
    func upload(_ resource: Resource) -> Observable<Progress> {
        return _token.flatMap { [weak self] token -> Observable<Progress> in
            guard let `self` = self else { return .empty() }
            return self._rawUpload(resource: resource, token: token)
        }
    }
    
    var uploadMapper: (Resource) -> Observable<Progress> {
        return { [weak self] in
            guard let `self` = self else { return .empty() }
            return self.upload($0)
        }
    }
}

private extension EVE.Uploader {
    @discardableResult
    func _lock<T>(_ todo: () -> T) -> T {
        _lock.lock(); defer { _lock.unlock() }
        return todo()
    }

    var _token: Observable<String> {
        return Observable.just(EVEUnit()).flatMap(EVE.workMapper(uploadToken))
            .map { $0.token }
    }
    
    func _rawUpload(resource: Resource, token: String) -> Observable<Progress> {
        return Observable.create { [m = _manager, weak self] subscribe in
            let complete: QNUpCompletionHandler = { info, key, resp in
                if info?.isOK == true, let key = resp?["key"] as? String {
                    subscribe.onNext(.finish(url: key._fileURLString))
                    subscribe.onCompleted()
                } else {
                    subscribe.onError(info?.error ?? UnknowError())
                }
            }
            var shouldCancel = false
            let option = QNUploadOption(mime: nil, progressHandler: { key, percent in
                syncInMain { subscribe.onNext(.uploading(progress: percent)) }
            }, params: nil, checkCrc: false) {
                return self?._lock { shouldCancel } ?? false
            }
            switch resource {
            case .file(let path):
                m.putFile(path, key: nil, token: token, complete: complete, option: option)
            case .asset(let asset):
                m.put(asset, key: nil, token: token, complete: complete, option: option)
            case .assetResource(let resource):
                m.put(resource, key: nil, token: token, complete: complete, option: option)
            case .data(let data):
                m.put(data, key: nil, token: token, complete: complete, option: option)
            }
            return Disposables.create {
                self?._lock { shouldCancel = true }
            }
        }
    }
}

extension EVE.Uploader {
    struct Config {
        static let bucketIdentifier = "http://p8cgjx6wx.bkt.clouddn.com"
        static let managerConfig = QNConfiguration.build { builder in
            // TODO: Build
        }
    }
}

fileprivate extension String {
    var _fileURLString: String {
        return EVE.Uploader.Config.bucketIdentifier + "/" + self
    }
}
