//
//  UserPreferenceConfig.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/25.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation

struct UserPreferenceConfig {
    private static let _keyForSupportNewLine = "SupportNewLine"
    static var supportNewLine: Bool {
        set {
            PreferenceStore.default[_keyForSupportNewLine] = newValue
        }
        
        get {
            return PreferenceStore.default[_keyForSupportNewLine] ?? false
        }
    }
}
