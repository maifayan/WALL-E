//
//  EVE.Connecter.swift
//  WALL-E
//
//  Created by Tangent on 2018/5/4.
//  Copyright © 2018 Tangent. All rights reserved.
//

import Foundation
import EVE

private let token = "YxjnaO2Cpin5zn4y0R70dr3e/3Kdej387ajkzyYAPkuhJhNuuzB043C+LkQ2IGT1/DWU/B8B4JM42hA+qEfaxf9mAfxvpVaX6BwnU4vZ6Bw9jTzXnlKVB7xx7rVQ/K4G"

extension EVE {
    final class Connecter {
        private let _service: EVEConnecter
        
        init() {
            GRPCCall.useInsecureConnections(forHost: EVE.Config.address)
            _service = EVEConnecter(host: EVE.Config.address)
        }
    }
}

extension EVE.Connecter {
    struct Config {
        static let minReconnectTime: TimeInterval = 2
        static let reconeectIteration: TimeInterval = 3
    }
}

extension EVE.Connecter {
    func connect() {
        let pipe = GRXBufferedPipe()
        let call = _service.rpcToConnect(withRequestsWriter: pipe) { done, event, error in
            guard let event = event else { return }
            print(event)
        }
        call.requestHeaders["authorization"] = token
        call.start()
    }
}
