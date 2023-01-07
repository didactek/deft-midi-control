//
//  MidiMessage.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import CoreMIDI

/// Represent a three-byte MIDI message.
public struct MidiMessage {
    public let subject: MCSubject
    public let id: UInt8
    public let value: UInt8
    
    public init(subject: MCSubject, id: UInt8, value: UInt8) {
        self.subject = subject
        self.id = id
        self.value = value
    }
    
    public init?(bytes: MIDIPacket.ByteCollection) {
        guard bytes.count >= 2 else {
            logger.warning("packet too small: \(bytes.count)")
            return nil
        }
        guard let subject = MCSubject(rawValue: bytes[0]) else {
            logger.warning("unknown subject code: \(bytes[0])")
            return nil
        }
        self.subject = subject
        self.id = bytes[1]
        self.value = bytes[2]
    }
}
