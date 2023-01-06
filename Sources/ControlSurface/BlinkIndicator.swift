//
//  BlinkIndicator.swift
//  
//
//  Created by Kit Transue on 2023-01-05.
//

import Foundation

public protocol BlinkIndicator: BinaryIndicator {
    var blink: IndicatorState { get set }
}

public enum IndicatorState: UInt8 {
    case off = 0
    case on = 0x7f
    case blink = 1
}

//extension BlinkIndicator {
//    public var isIlluminated: Bool {
//        get { blink == .on }
//        set { blink = newValue ? .on : .off }
//    }
//}
