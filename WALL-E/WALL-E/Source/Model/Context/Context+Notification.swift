//
//  Context+Notification.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/11.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import RxSwift

extension Context {
    var typingObservable: Observable<String> {
        return typingSubject.asObserver()
    }
    
    var messageObservable: Observable<String> {
        return messageSubject.asObserver()
    }
}
