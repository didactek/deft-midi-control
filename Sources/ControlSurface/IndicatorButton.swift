//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation

/// A button in Mackie mode.
public protocol SurfaceButton {
    var isPressed: Bool {get}
}


public class IndicatorButton: SurfaceControl, SurfaceButton, SurfaceIndicator {
    weak var endpoint: MidiEndpoint?
    let midiAddress: UInt8
    
    @Published
    public var indicator: IndicatorState = .off {
        didSet {
            endpoint?.sendMidi(message: MidiMessage(subject: .buttonMC, id: self.midiAddress, value: indicator.rawValue))
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
