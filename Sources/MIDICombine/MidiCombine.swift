//
//  MidiCombine.swift
//  
//
//  Created by Kit Transue on 2023-01-07.
//

import Foundation
import CoreMIDI

/// Manage all the structures required to maintain a conversation with a MIDI device.
public struct MidiCombine {
    public let endpoint: MidiEndpoint // weak? Var?
    public let input: MidiPublisher
    
    /// Set up ports and endpoints for communicating with one of the MIDI devices available
    /// to the program.
    ///
    /// - parameter sourceIndex: system index for the device. "0" is probably correct
    /// when only one device is connected to the system.
    public init(sourceIndex: Int) throws {
        let sourceEndpoint = MIDIGetSource(sourceIndex)
        let sinkEndpoint = MIDIGetDestination(sourceIndex)

        var client = MIDIClientRef()
        let clientResult = MIDIClientCreate("MIDI subsystem client" as CFString, nil, /*notifyRefCon*/nil, &client)
        guard clientResult == noErr else {
            throw MidiCombineError.midi("MIDIClientCreate error: \(clientResult)")
        }
        
        var outputPort = MIDIPortRef()
        let outputCreateResult = MIDIOutputPortCreate(client, "output port" as CFString, &outputPort)
        guard outputCreateResult == noErr else {
            throw MidiCombineError.midi("MIDIOutputPortCreate error: \(outputCreateResult)")
        }
        
        endpoint = MidiEndpoint(port: outputPort, endpoint: sinkEndpoint)
        input = try MidiPublisher(client: client, sourceEndpoint: sourceEndpoint)
    }
}
