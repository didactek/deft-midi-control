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
//    var feedback: AnyCancellable? = nil
    
    public enum Event {
        case pressed
        case released
    }

    let midiAddress: UInt8
    
    @Published
    public var illuminated = false
    
    @Published
    public var event: Event
    
    init(endpoint: MidiEndpoint, address: UInt8) {
        self.event = .released
        self.midiAddress = address
        self.endpoint = endpoint
        
        self.updater = $illuminated.sink { newValue in
            endpoint.sendMidi(message: MidiMessage(subject: .buttonMC, id: self.midiAddress, value: newValue ? 0x7f : 0))
        }

        #if false
        self.feedback = $event.sink { event in
            switch event {
            case .pressed:
                self.illuminated = !self.illuminated  // toggle
//                self.illuminated = true  // momentary
            case .released:
                break  // toggle
//                self.illuminated = false // momentary
            }
        }
        #endif
    }

    public func action(message: MidiMessage) {
        guard message.subject == .buttonMC else {
            fatalError("button got unexpected action \(message)")
        }
        let pressed = message.value != 0
        event = pressed ? Event.pressed : Event.released
    }
}
