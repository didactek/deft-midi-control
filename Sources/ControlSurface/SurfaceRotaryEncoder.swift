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
public class SurfaceRotaryEncoder: MidiResponder, DeltaEncoderProtocol, MomentaryButton, MultiSegmentIndicator {
    let delta: DeltaEncoder
    public var change: any Publisher<Int, Never> { delta.change }
    
    let button: SurfaceButton
    public var isPressed: any Publisher<Bool, Never> { button.isPressed }
    
    // FIXME: surely there's a way to forward more easily? Fixing LoD should not be so ugly.
    var _indicator: CircularIndicator
    public var mode: MultiSegmentIndicatorMode {
        get { _indicator.mode}
        set { _indicator.mode = newValue }
    }
    public var indicator: ControlValue {
        get { _indicator.indicator }
        set { _indicator.indicator = newValue }
    }
    
    init(delta: DeltaEncoder, button: SurfaceButton, indicator: CircularIndicator) {
        self.delta = delta
        self.button = button
        self._indicator = indicator
    }
    
    func action(message: MidiMessage) {
        delta.action(message: message)
        button.action(message: message)
    }
}
