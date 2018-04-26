//
//  Settings.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/26.
//  Copyright © 2018 Tangent. All rights reserved.
//

import UIKit

enum Settings { }

let globalPreference = PreferenceStore(identifier: "global")

extension Settings {
    enum EnterKeyOptions: String {
        case send
        case newline
    }
}

extension Settings {
    static var enterKeyOptions: EnterKeyOptions {
        set {
            globalPreference["enterKeyOptions"] = newValue.rawValue
        }
        get {
            return EnterKeyOptions(rawValue: globalPreference["enterKeyOptions"] ?? "send") ?? .send
        }
    }
    
    static var showMessageDate: Bool {
        set {
            globalPreference["showMessageDate"] = newValue
        }
        get {
            return globalPreference["showMessageDate"] ?? false
        }
    }
}
