//
//  SurfaceRotaryEncoder.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation

class SurfaceRotaryEncoder: SurfaceControl {
    let midiAddress: UInt8
    
    // FIXME: want min/max to be sort of a range; need it to map to another range (1..11 or 1..5)
    var min: Int = 1
    var max: Int = 11
    var value: Int = 6
    
    init(address: UInt8) {
        midiAddress = address
    }
    
    enum DisplayMode {
        case singleTick
        case fromLeft
        case fromCenter
        case mirror
    }
    
    var mode: DisplayMode = .fromLeft
    
    func action(message: MidiMessage) {
        switch message.subject {
        case .encoderChangeMC:
            let magnitude = Int(message.value & 0x07)
            let clockwise = message.value < 0x40
            if clockwise {
                value = Swift.min(max, value + magnitude)
            } else {
                value = Swift.max(min, value - magnitude)
            }
            print("value: \(value)")
        default:
            break
        }
    }
    
    func feedback() -> MidiMessage? {
        let domain = max - min
        let range = (mode == .mirror) ? 6 : 11
        let offset: Int
        switch mode {
        case .singleTick:
            offset = 0
        case .fromCenter:
            offset = 16
        case .fromLeft:
            offset = 32
        case .mirror:
            offset = 48
        }
        // FIXME: range calculation off-by-one at end
        let position = (value - min) * range / domain + 1
        // FIXME: having offset hardcoded is probably not OK.
        let msg = MidiMessage(subject: .encoderChangeMC, id: midiAddress + 0x20, value: UInt8(offset + position))
        debugPrint(msg)
        return msg
    }
    
}
