//
//  log.swift
//  WALL-E
//
//  Created by Tangent on 2018/4/27.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation

func log(_ error: Error) {
    print("Error: \(error)")
}

func log(_ str: String) {
    print(str)
}

func log(file: String = #file, function: String = #function) {
    print("\(file) ==> \(function)")
}
