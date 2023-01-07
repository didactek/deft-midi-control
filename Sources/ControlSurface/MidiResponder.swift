//
//  MidiResponder.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation

/// Responder protocol. Responders should ignore messages not intended for them
///
/// Responders that only care about one address can get the filtering automatically by
/// adopting the ``SingleAddressResponder`` protocol.
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
