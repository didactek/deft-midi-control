//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation

/// A button in Mackie state.
public class SurfaceButton {
    enum Mode {
        case momentary
        case toggle
    }

    let midiAddress: UInt8
    
    var selected: Bool = false
    var mode: Mode = .momentary
    
    public init(address: Int) {
        midiAddress = UInt8(address)
    }
    
    /// A MIDI message that will set the surface's indicators to reflect the button state
    public func feedback() -> MidiMessage {
        return MidiMessage(subject: .buttonMC, id: midiAddress, value: selected ? 0x7f : 0)
    }
}
