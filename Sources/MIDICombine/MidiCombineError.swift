//
//  MidiCombineError.swift
//  
//
//  Created by Kit Transue on 2023-01-07.
//  Copyright © 2023 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import DeftLog

var logger = DeftLog.logger(label: "com.didactek.midi-combine")

enum MidiCombineError: Error {
    case midi(String)
}
