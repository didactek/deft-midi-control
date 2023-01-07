//
//  CircularIndicator.swift
//  
//
//  Created by Kit Transue on 2023-01-06.
//

import Foundation
import MIDICombine

public class CircularIndicator: MidiInitiator {
    public enum DisplayMode {
        case singleTick
        case fromLeft
        case fromCenter
        case mirror
    }
    
    public var mode: DisplayMode
    
    @Published
    public var indicator = ControlValue(range: 1...11, value: 6) {
        didSet {
            endpoint?.sendMidi(message: self.feedback(value: indicator))
        }
    }
    
    init(endpoint: MidiEndpoint, midiAddress: UInt8, mode: DisplayMode = .fromLeft) {
        self.mode = mode
        super.init(endpoint: endpoint, midiAddress: midiAddress)
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
                              id: midiAddress,
                              value: UInt8(offset + position))
        return msg
    }
}
