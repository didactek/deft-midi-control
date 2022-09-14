//
//  SurfaceRotaryEncoder.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation
import Combine

public class SurfaceRotaryEncoder: SurfaceControl {
    weak var endpoint: MidiEndpoint?
    var updater: AnyCancellable? = nil
    
    let midiAddress: UInt8
    let feedbackAddress: UInt8
    
    @Published
    public var indicator = ControlValue(range: 1...11, value: 6)

    public var mode: DisplayMode

    init(endpoint: MidiEndpoint, address: UInt8, feedbackAddress: UInt8? = nil, mode: DisplayMode = .fromLeft) {
        self.endpoint = endpoint
        midiAddress = address
        self.feedbackAddress = feedbackAddress ?? (address + 0x20)
        self.mode = mode
        
        updater = $indicator.sink { newValue in
            endpoint.sendMidi(message: self.feedback(value: newValue))
        }
    }
    
    public enum DisplayMode {
        case singleTick
        case fromLeft
        case fromCenter
        case mirror
    }
    
    func action(message: MidiMessage) {
        switch message.subject {
        case .encoderChangeMC:
            let magnitude = Int(message.value & 0x07)
            let clockwise = message.value < 0x40
            if clockwise {
                indicator = indicator.adjusted(by: magnitude)
            } else {
                indicator = indicator.adjusted(by: -magnitude)
            }
        default:
            break
        }
    }
    
    func feedback(value: ControlValue) -> MidiMessage {
        let fullScale = (mode == .mirror) ? 6 : 11
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
        let position = value.interpolated(as: 1 ... fullScale).value
        let msg = MidiMessage(subject: .encoderChangeMC,
                              id: feedbackAddress,
                              value: UInt8(offset + position))
        return msg
    }
    
}
