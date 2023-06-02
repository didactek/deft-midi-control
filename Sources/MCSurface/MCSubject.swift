//
//  MCSubject.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation
import MIDICombine

/// Subject codes produced or consumed by the Behringer XTouch Mini in Mackie Control
/// emulation mode.
///
/// - Important: Other devices--including other control surfaces--are likely to support additional codes,
/// or may adopt semantics different than those here.
public enum MCSubject: UInt8 {
    /// Button changed state (pressed or released) in MC mode. Value is 0x7f (pressed) or 0x00 (released).
    /// May be written to provide feedback: 0 = off; 1 = blink; 0x7f = on.
    case buttonMC = 0x90
    /// Rotary encoder moved. 0x0{n} = n clicks clockwise. 0x4{n} = n clicks counterclockwise. Largest observed n is 7?
    /// May be written to set indicator position. Write position is interesting:
    /// - 0: off
    /// - 1 - 11: light single indicated tick
    /// - 17- 27: light from position to center: 17 full left; 27 full right
    /// - 33-43: light from left to position
    /// - 49-54: from center outwards symmetrically
    /// - Note: patterns above repeats at offset 64
    /// - 127: all on
    case encoderChangeMC = 0xb0
    /// Report MC Fader position
    case faderPositionMC = 0xe8
}

extension MidiMessage {
    public init(subject: MCSubject, id: UInt8, value: UInt8) {
        self.init(subject: subject.rawValue, id: id, value: value)
    }
}
