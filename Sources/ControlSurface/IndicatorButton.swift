//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation

/// A button in Mackie mode.
///
/// Button reports a state change once when it is pressed and another time when it is released.
public protocol MomentaryButton {
    var isPressed: Bool {get}
}

public class SurfaceButton: SurfaceControl, MomentaryButton {
    weak var endpoint: MidiEndpoint?
    let midiAddress: UInt8
    
    @Published
    public private(set) var isPressed = false
    
    init(endpoint: MidiEndpoint, address: UInt8) {
        self.endpoint = endpoint
        self.midiAddress = address
    }

    public func action(message: MidiMessage) {
        guard message.subject == .buttonMC else {
            logger.warning("button got unexpected action \(message)")
            return
        }
        isPressed = message.value != 0
    }
}

public class IndicatorButton: SurfaceButton, SurfaceIndicator {
    @Published
    public var indicator: IndicatorState = .off {
        didSet {
            endpoint?.sendMidi(message: MidiMessage(subject: .buttonMC, id: self.midiAddress, value: indicator.rawValue))
        }
    }

    override init(endpoint: MidiEndpoint, address: UInt8) {
        super.init(endpoint: endpoint, address: address)
    }
}
