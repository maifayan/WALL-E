//
//  Settings.Model.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/27.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation

extension Settings {
    final class Model {
        let showMessageDate: Pipe<Bool> = Pipe { Settings.showMessageDate = $0 }
        private(set) lazy var enterKeyOption: Pipe<EnterKeyOptions> = Pipe { [weak self] in Settings.enterKeyOptions = $0; self?.enterKeyOption.right?($0) }
        
        init() { }
        
        func loadSettings() {
            enterKeyOption.right?(Settings.enterKeyOptions)
            showMessageDate.right?(Settings.showMessageDate)
        }
    }
}

private extension Settings.Model {
}

extension Settings.Model {
    final class Pipe<T> {
        let left: (T) -> ()
        var right: ((T) -> ())?
        
        init(left: @escaping (T) -> ()) {
            self.left = left
        }
    }
}
