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

public class SurfaceButton: MidiResponder, MomentaryButton, SingleAddressResponder {
    let midiAddress: UInt8
    
    @Published
    public private(set) var isPressed = false
    
    init(address: UInt8) {
        self.midiAddress = address
    }

    public func action(subject: MidiSubject, value: UInt8) {
        guard subject == .buttonMC else {
            logger.warning("button got unexpected action \(subject)")
            return
        }
        isPressed = value != 0
    }
}

public class IndicatorButton: SurfaceButton, BlinkIndicator {
    weak var endpoint: MidiEndpoint?

    @Published
    public var blink: BlinkState = .off {
        didSet {
            endpoint?.sendMidi(message: MidiMessage(subject: .buttonMC, id: self.midiAddress, value: blink.rawValue))
        }
    }
    
    public var isIlluminated: Bool {
        get { blink == .steady }
        set { blink = newValue ? .steady : .off }
    }

    init(endpoint: MidiEndpoint, address: UInt8) {
        self.endpoint = endpoint
        super.init(address: address)
    }
}
