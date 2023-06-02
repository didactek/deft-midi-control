//
//  ControlSurfaceError.swift
//  
//
//  Created by Kit Transue on 2022-12-29.
//

import Foundation
import DeftLog

enum ControlSurfaceError: Error {
    case midi(String)
}

let logger = DeftLog.logger(label: "com.didactek.xtouch")
