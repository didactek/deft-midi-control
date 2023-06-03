//
//  BlinkIndicator.swift
//  
//
//  Created by Kit Transue on 2023-01-05.
//  Copyright © 2023 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

public protocol BlinkIndicator {
    var blink: BlinkState { get set }
}

public enum BlinkState: UInt8 {
    case off = 0
    case steady = 0x7f
    case blink = 1
}
