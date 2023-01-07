//
//  MidiCombineError.swift
//  
//
//  Created by Kit Transue on 2023-01-07.
//

import Foundation
import DeftLog

var logger = DeftLog.logger(label: "com.didactek.midi-combine")

enum MidiCombineError: Error {
    case midi(String)
}
