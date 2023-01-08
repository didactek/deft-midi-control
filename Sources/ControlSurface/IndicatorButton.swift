//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation
import MIDICombine

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

    public init(endpoint: MidiEndpoint, address: UInt8) {
        self.endpoint = endpoint
        super.init(address: address)
    }
}
