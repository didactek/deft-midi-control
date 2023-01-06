//
//  SurfaceFader.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation
import Combine

/// An analog fader.
///
/// The fader has 128 steps. 0 is at the bottom of the slider range; 127 at the top.
/// Scale is linear.
///
/// It is not motorized, so sets of the value
/// have no effect on value but can be used to set the interpolated range.
///
/// The initial value must be provided: the value is unknown until the slider is moved
/// and the controller sends a notification of change message.
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
