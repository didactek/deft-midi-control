//
//  SurfaceRotaryEncoder.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation

public class SurfaceRotaryEncoder: SingleAddressResponder {
    let midiAddress: UInt8

    /// Events describing how far the controller was rotated.
    @Published
    public var change = 0


    init(address: UInt8) {
        midiAddress = address
    }
    
    func action(subject: MidiSubject, value: UInt8) {
        switch subject {
        case .encoderChangeMC:
            let magnitude = Int(value & 0x07)
            let clockwise = value < 0x40
            if clockwise {
                change = magnitude
            } else {
                change = -magnitude
            }
        default:
            break
        }
    }
}
