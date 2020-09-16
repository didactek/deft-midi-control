//
//  MidiMessage.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

/// Represent a three-byte MIDI message.
public struct MidiMessage {
    public let message: UInt8
    public let id: UInt8
    public let value: UInt8
    
    public init(message: UInt8, id: UInt8, value: UInt8) {
        self.message = message
        self.id = id
        self.value = value
    }
}
