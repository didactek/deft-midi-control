//
//  SurfaceControl.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation

protocol SurfaceControl {
    /// Take action based on an incoming MIDI message.
    func action(message: MidiMessage)
    
    /// Instructions for updating control presentation to represent its state. ("MIDI Feedback")
    func feedback() -> MidiMessage?
    
    /// Address that this control is interested in
    var midiAddress: UInt8 { get }

    /// Endpoint to send messages to
    var endpoint: MidiEndpoint? { get }
    
    /// Update the control surface setting
    func update()
}

extension SurfaceControl {
    func update() {
        if let endpoint = endpoint {
            endpoint.sendMidi(message: feedback())
        }
    }
}
