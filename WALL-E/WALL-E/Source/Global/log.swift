//
//  log.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/27.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation

func log(file: String = #file, function: String = #function) {
    print("\(file) ==> \(function)")
}
