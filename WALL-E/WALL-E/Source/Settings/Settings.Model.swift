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
        
        let enterKeyOptionsVal = BehaviorRelay<EnterKeyOptions>(value: .send)
        let showDateVal = BehaviorRelay(value: false)
        
        func loadSettings() {
            enterKeyOptionsVal.accept(Settings.enterKeyOptions)
            showDateVal.accept(Settings.showMessageDate)
            
            enterKeyOptionsVal.subscribe(onNext: { Settings.enterKeyOptions = $0 }).disposed(by: _bag)
            showDateVal.subscribe(onNext: { Settings.showMessageDate = $0 }).disposed(by: _bag)
        }
        
        deinit {
            log()
        }
        
        private let _bag = DisposeBag()
    }
}
