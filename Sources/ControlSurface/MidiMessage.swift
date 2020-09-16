//
//  MidiMessage.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

/// Represent a three-byte MIDI message.
public struct MidiMessage {
    public let subject: UInt8
    public let id: UInt8
    public let value: UInt8
    
    public init(subject: MidiSubject, id: UInt8, value: UInt8) {
        self.subject = subject.rawValue
        self.id = id
        self.value = value
    }
}
