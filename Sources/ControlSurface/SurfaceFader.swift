//
//  SurfaceFader.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation

public class SurfaceFader: SurfaceControl {
    public var value: UInt8
    let midiAddress: UInt8
    weak var endpoint: MidiEndpoint?

    func action(message: MidiMessage) {
        switch message.subject {
        case .faderPositionMC, .layeredFaderPosition:
            value = message.value
        default:
            break
        }
    }
    
    /// Fader isn't motorized; can't provide feedback
    func feedback() -> MidiMessage? {
        return nil
    }
    
    public init(id: UInt8, starting value: UInt8) {
        self.midiAddress = id
        self.value = value
    }
}
