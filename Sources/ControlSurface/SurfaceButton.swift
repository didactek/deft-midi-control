//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation
import Combine

/// A button in Mackie mode.
public class SurfaceButton: SurfaceControl {
    weak var endpoint: MidiEndpoint?
    var updater: AnyCancellable? = nil
    
    public enum Mode {
        case momentary
        case toggle
    }

    let midiAddress: UInt8
    
    
    @Published
    public var selected: Bool = false

    var mode: Mode
    
    init(endpoint: MidiEndpoint, address: UInt8, mode: Mode = .toggle) {
        self.mode = mode
        midiAddress = address
        self.endpoint = endpoint
        
        self.updater = $selected.sink { [self] newValue in
            endpoint.sendMidi(message:  MidiMessage(subject: .buttonMC, id: midiAddress, value: newValue ? 0x7f : 0))
        }
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
        return nil
    }
}
