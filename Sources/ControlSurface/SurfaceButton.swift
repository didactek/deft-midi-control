//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation

/// A button in Mackie mode.
public class SurfaceButton: SurfaceControl {
    weak var endpoint: MidiEndpoint?
    
    public enum Mode {
        case momentary
        case toggle
    }

    let midiAddress: UInt8
    
    public var selected: Bool = false {
        didSet {
            if let endpoint = endpoint {
                endpoint.sendMidi(message: feedback())
            }
        }
    }
    var mode: Mode
    
    init(endpoint: MidiEndpoint, address: UInt8, mode: Mode = .toggle) {
        self.mode = mode
        midiAddress = address
        self.endpoint = endpoint
    }
    
    public func action(message: MidiMessage) {
        guard message.subject == .buttonMC else {
            fatalError("button got unexpected action \(message)")
        }
        let pressed = message.value != 0
        switch mode {
        case .toggle:
            if pressed {
                selected.toggle()
            }
        case .momentary:
            if pressed {
                selected = true
            } else {
                selected = false
            }
        }
    }
    
    /// A MIDI message that will set the surface's indicators to reflect the button state
    public func feedback() -> MidiMessage? {
        return MidiMessage(subject: .buttonMC, id: midiAddress, value: selected ? 0x7f : 0)
    }
}
