//
//  MidiCombine.swift
//  
//
//  Created by Kit Transue on 2023-01-07.
//

import Foundation
import CoreMIDI

public struct MidiCombine {
    public let endpoint: MidiEndpoint // weak? Var?
    public let input: MidiPublisher
    
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
