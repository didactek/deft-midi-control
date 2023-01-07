//
//  SurfaceRotaryEncoder.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation

/// Base class for objects that will send to an endpoint; generally indicators that set state on the control
public class MidiInitiator {
    weak var endpoint: MidiEndpoint?
    let midiAddress: UInt8
    
    init(endpoint: MidiEndpoint, midiAddress: UInt8) {
        self.endpoint = endpoint
        self.midiAddress = midiAddress
    }
}

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


public class SurfaceRotaryEncoder: SurfaceControl {
    let midiAddress: UInt8

    /// Events describing how far the controller was rotated.
    @Published
    public var change = 0


    init(address: UInt8) {
        midiAddress = address
    }
    
    func action(message: MidiMessage) {
        switch message.subject {
        case .encoderChangeMC:
            let magnitude = Int(message.value & 0x07)
            let clockwise = message.value < 0x40
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
