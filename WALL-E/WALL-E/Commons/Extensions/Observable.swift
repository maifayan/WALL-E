//
//  Observable.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/23.
//  Copyright © 2018 Tangent. All rights reserved.
//

import RxSwift

extension ObservableType {
    func ignoreNil<T>() -> Observable<T> where E == T? {
        return filter { $0 != nil }.map { $0! }
    }
}
