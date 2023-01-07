//
//  MidiInitiator.swift
//  
//
//  Created by Kit Transue on 2023-01-06.
//

import Foundation
import MIDICombine

// Base class for objects that will send to an endpoint; generally indicators that set state on the control
public class MidiInitiator {
    weak var endpoint: MidiEndpoint?
    let midiAddress: UInt8
    
    init(endpoint: MidiEndpoint, midiAddress: UInt8) {
        self.endpoint = endpoint
        self.midiAddress = midiAddress
    }
}
