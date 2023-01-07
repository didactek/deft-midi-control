//
//  SurfaceRotaryEncoder.swift
//  XTouchCA
//
//  Created by Kit Transue on 2023-01-06.
//

import Foundation

/// An object that represents all the functions of the control knob: a rotary delta encoder,
/// a pushbutton swtich, and a ring indicator.
class SurfaceRotaryEncoder {
    let delta: DeltaEncoder
    let button: MomentaryButton
    let indicator: CircularIndicator
    
    init(delta: DeltaEncoder, button: MomentaryButton, indicator: CircularIndicator) {
        self.delta = delta
        self.button = button
        self.indicator = indicator
    }
}
