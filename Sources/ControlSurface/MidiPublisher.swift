//
//  MidiPublisher.swift
//  
//
//  Created by Kit Transue on 2020-09-17.
//

import Foundation
import CoreMIDI
import Combine

public typealias MidiNotifier = PassthroughSubject<MidiMessage, Never>

public class MidiPublisher {
    public let publisher = MidiNotifier()
    
    init(client: MIDIClientRef, sourceEndpoint: MIDIPortRef) {
        let readProcRefCon = MidiPublisherRegistry.register(publisher: publisher)

        var inputPort = MIDIPortRef()
        let portResult = MIDIInputPortCreate(
            client, "input port" as CFString,
            publishCallback,
            readProcRefCon, &inputPort)
        guard portResult == noErr else {
            fatalError("MIDIInputPortCreate error: \(portResult)")
        }
        
        let bindResult = MIDIPortConnectSource(inputPort, sourceEndpoint, /*srcConnRefCon*/nil)
        guard bindResult == noErr else {
            fatalError("MIDIPortConnectSource error: \(bindResult)")
        }
    }
}

/// Map "reference pointers" to MidiNotifiers.
/// This gets around the "A C function pointer cannot be formed from a closure that captures context" problem with closures:.
/// The "reference pointer" is just a pointer-sized key that is borrowed by the MIDI callback.
class MidiPublisherRegistry {
    class weakRef {
        weak var value: MidiNotifier?
        init(_ value: MidiNotifier) {
            self.value = value
        }
    }
    
    static var servingNext = 44556
    static var registry: [UnsafeMutableRawPointer: weakRef] = [:]

    static func lookup(ref: UnsafeMutableRawPointer) -> MidiNotifier? {
        return registry[ref]?.value
    }

    static func register(publisher: MidiNotifier) -> UnsafeMutableRawPointer {
        servingNext += 1
        let fakePtr = UnsafeMutableRawPointer(bitPattern: servingNext)!
        registry[fakePtr] = weakRef(publisher)
        return fakePtr
    }
}


func publishCallback(_ packets: UnsafePointer<MIDIPacketList>, _ readProcRefCon: UnsafeMutableRawPointer?, _ srcConnRefCon: UnsafeMutableRawPointer?) {
    // FIXME: make lookup more optional-friendly
    guard let publisher = MidiPublisherRegistry.lookup(ref: readProcRefCon!) else {
        print("Surface not found")
        return
    }
    
    for packet in packets.unsafeSequence() {
        let bytes = packet.bytes()
        if let msg = MidiMessage(bytes: bytes) {
            publisher.send(msg)
        }
    }
}
