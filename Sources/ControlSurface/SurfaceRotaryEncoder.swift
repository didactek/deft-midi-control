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
public class SurfaceRotaryEncoder: MidiResponder, DeltaEncoderProtocol {
    // FIXME: surface component interfaces to avoid LoD violations
    let delta: DeltaEncoderProtocol
    public var change: any Publisher<Int, Never> { delta.change }
    
    public let button: SurfaceButton
    public let indicator: CircularIndicator
    
    init(delta: DeltaEncoderProtocol, button: SurfaceButton, indicator: CircularIndicator) {
        self.delta = delta
        self.button = button
        self.indicator = indicator
    }
    
    func action(message: MidiMessage) {
        delta.action(message: message)
        button.action(message: message)
    }
}
