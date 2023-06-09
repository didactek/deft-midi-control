//
//  MidiMessage.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import CoreMIDI

/// A hree-byte MIDI message.
public struct MidiMessage {
    public let subject: UInt8
    public let id: UInt8
    public let value: UInt8
    
    public init(subject: UInt8, id: UInt8, value: UInt8) {
        self.subject = subject
        self.id = id
        self.value = value
    }
    
    public init?(bytes: MIDIPacket.ByteCollection) {
        guard bytes.count >= 3 else {
            logger.warning("packet too small: \(bytes.count)")
            return nil
        }
        self.subject = bytes[0]
        self.id = bytes[1]
        self.value = bytes[2]
    }
}
