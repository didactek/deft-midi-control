//
//  SurfaceFader.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation
import Combine

public class SurfaceFader: SurfaceControl {
    @Published
    public var value: ControlValue
    
    let faderValues = ControlValue(range: 0...127, value: 63)

    let midiAddress: UInt8
    weak var endpoint: MidiEndpoint?

    func action(message: MidiMessage) {
        switch message.subject {
        case .faderPositionMC, .layeredFaderPosition:
            // fader has a fixed range; if that's been changed: interpolate.
            value = faderValues.changed(to: Int(message.value)).interpolated(as: value.range)
        default:
            break
        }
    }
    
    public init(id: UInt8, starting value: Int) {
        self.midiAddress = id
        self.value = ControlValue(range: 0...127, value: value)
    }
}
