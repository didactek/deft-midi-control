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
}

protocol SingleAddressResponder: MidiResponder {
    var midiAddress: UInt8 { get }
    func action(subject: MidiSubject, value: UInt8)
}

extension SingleAddressResponder {
    func action(message: MidiMessage) {
        guard message.id == midiAddress else {return}
        action(subject: message.subject, value: message.value)
    }
}
