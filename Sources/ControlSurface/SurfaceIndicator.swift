//
//  SurfaceIndicator.swift
//  
//
//  Created by Kit Transue on 2023-01-05.
//

import Foundation

public protocol SurfaceIndicator {
    var indicator: IndicatorState { get set }
}

public enum IndicatorState: UInt8 {
    case off = 0
    case on = 0x7f
    case blink = 1
}
