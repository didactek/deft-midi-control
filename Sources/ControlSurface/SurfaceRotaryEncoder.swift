//
//  SurfaceRotaryEncoder.swift
//  XTouchCA
//
//  Created by Kit Transue on 2023-01-06.
//

import Foundation

/// An object that represents all the functions of the control knob: a rotary delta encoder,
/// a pushbutton swtich, and a ring indicator.
class SurfaceRotaryEncoder: MidiResponder {
    let delta: DeltaEncoder
    let button: SurfaceButton
    let indicator: CircularIndicator
    
    init(delta: DeltaEncoder, button: SurfaceButton, indicator: CircularIndicator) {
        self.delta = delta
        self.button = button
        self.indicator = indicator
    }
    
    func action(message: MidiMessage) {
        delta.action(message: message)
        button.action(message: message)
    }
}
