//
//  MidiResponder.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation

/// Protocol  required to route messages to an interested object. Incoming messages addresses
/// are compared against address and action is called  on a match.
protocol MidiResponder {
    /// Take action based on an incoming MIDI message.
    func action(message: MidiMessage)
    
    /// Address that this control is interested in
    var midiAddress: UInt8 { get }
}

