//
//  SurfaceRotaryEncoder.swift
//  XTouchCA
//
//  Created by Kit Transue on 2023-01-06.
//

import Foundation
import MIDICombine
import Combine

/// An object that represents all the functions of the control knob: a rotary delta encoder,
/// a pushbutton swtich, and a ring indicator.
public class SurfaceRotaryEncoder: MidiResponder, DeltaEncoderProtocol, MomentaryButton {
    // FIXME: surface component interfaces to avoid LoD violations
    let delta: DeltaEncoder
    public var change: any Publisher<Int, Never> { delta.change }
    
    let button: SurfaceButton
    public var isPressed: any Publisher<Bool, Never> { button.isPressed }
    public let indicator: CircularIndicator
    
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
