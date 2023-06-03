//
//  MidiResponder.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import MIDICombine

/// Responder protocol. Responders should ignore messages not intended for them
///
/// Responders that only care about one address can get the filtering automatically by
/// adopting the ``SingleAddressResponder`` protocol.
public protocol MidiResponder {
    /// Take action based on an incoming MIDI message.
    func action(message: MidiMessage)
}

/// Automatically route events to responders that provide a single address they
/// are interested in.
public protocol SingleAddressResponder: MidiResponder {
    var midiAddress: UInt8 { get }
    func action(subject: MCSubject, value: UInt8)
}

extension SingleAddressResponder {
    public func action(message: MidiMessage) {
        guard message.id == midiAddress else {return}
        guard let subject = MCSubject(rawValue: message.subject) else {
            logger.warning("unknown subject code in: \(message)")
            return
        }
        action(subject: subject, value: message.value)
    }
}
