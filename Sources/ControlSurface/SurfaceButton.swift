//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation

/// A button in Mackie mode.
public class SurfaceButton: SurfaceControl {
    weak var endpoint: MidiEndpoint?
    let midiAddress: UInt8
    
    @Published
    public var illuminated = false {
        didSet {
            endpoint?.sendMidi(message: MidiMessage(subject: .buttonMC, id: self.midiAddress, value: illuminated ? 0x7f : 0))
        }
    }
    
    @Published
    public private(set) var isPressed = false
    
    init(endpoint: MidiEndpoint, address: UInt8) {
        self.midiAddress = address
        self.endpoint = endpoint
    }

    public func action(message: MidiMessage) {
        guard message.subject == .buttonMC else {
            logger.warning("button got unexpected action \(message)")
            return
        }
        isPressed = message.value != 0
    }
}
