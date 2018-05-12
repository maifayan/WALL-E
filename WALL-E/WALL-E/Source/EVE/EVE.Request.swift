//
//  EVE.Request.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import EVE
import RxSwift

extension EVE {
    final class Request {
        private let _syncService = EVESync(host: Config.address)
        private let _updateService = EVEUpdate(host: Config.address)
    
        // Unowned reference to Context!
        private unowned let _context: Context
        
        init(_ context: Context) {
            _context = context
        }

        // For Sync
        private(set) lazy var syncContacts = WorkItem(
            _syncService.rpcToSyncContacts,
            .auth(self._context.token)
        )
        
        private(set) lazy var syncMessages = WorkItem(
            _syncService.rpcToSyncMessages,
            .auth(self._context.token)
        )
        
        // For Update
        private(set) lazy var updateMember = WorkItem(
            _updateService.rpcToUpdateMember,
            .auth(self._context.token)
        )
        
        private(set) lazy var updateRobot = WorkItem(
            _updateService.rpcToUpdateRobot,
            .auth(self._context.token)
        )
        
        private(set) lazy var createRobot = WorkItem(
            _updateService.rpcToCreate,
            .auth(self._context.token)
        )
        
        private let _updateBag = DisposeBag()
    }
}

extension EVE.Request {
    func updateMemberIfNeeds(iconURL: String? = nil, name: String? = nil, phone: String? = nil) {
        let me = _context.me
        let info = EVEMemberUpdateInfo()
        var shouldUpdate = false
        if let iconURL = iconURL, iconURL != me.iconURL {
            info.iconURL = iconURL
            shouldUpdate = true
        }
        if let name = name, name != me.name {
            info.name = name
            shouldUpdate = true
        }
        if let phone = phone, phone != me.phone {
            info.phone = phone
            shouldUpdate = true
        }
        guard shouldUpdate else { return }
        EVE.workWith(updateMember, request: info)
            .subscribe(onError: {
                log("update member error!")
                log($0)
            })
            .disposed(by: _updateBag)
    }
}
