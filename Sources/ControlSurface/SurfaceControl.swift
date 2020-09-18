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
    
    /// Address that this control is interested in
    var midiAddress: UInt8 { get }

    /// Endpoint to send messages to
    var endpoint: MidiEndpoint? { get }
}
