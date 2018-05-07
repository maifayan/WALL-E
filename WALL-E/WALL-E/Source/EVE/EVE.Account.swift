//
//  EVE.Account.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/6.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import EVE
import RxSwift

extension EVE {
    final class Account {
        static let shared = Account()

        private let _service = EVEAccountService(host: Config.address)

        private(set) lazy var login = WorkItem(_service.rpcToLogin)
        private(set) lazy var register = WorkItem(_service.rpcToRegister)
    }
}
