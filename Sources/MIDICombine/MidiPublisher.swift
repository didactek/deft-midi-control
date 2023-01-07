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
    
    public init(client: MIDIClientRef, sourceEndpoint: MIDIPortRef) throws {
        let readProcRefCon = MidiPublisherRegistry.register(publisher: publisher)

        var inputPort = MIDIPortRef()
        let portResult = MIDIInputPortCreate(
            client, "input port" as CFString,
            publishCallback,
            readProcRefCon, &inputPort)
        guard portResult == noErr else {
            throw MidiCombineError.midi("MIDIInputPortCreate error: \(portResult)")
        }
        
        let bindResult = MIDIPortConnectSource(inputPort, sourceEndpoint, /*srcConnRefCon*/nil)
        guard bindResult == noErr else {
            throw MidiCombineError.midi("MIDIPortConnectSource error: \(bindResult)")
        }
    }
}

/// Give MidiNotifiers unique, persistent tokens that may be stored as C-style ("reference pointer") handles.
///
/// Implemented as a global map of "reference pointers" to MidiNotifiers.
///
/// This gets around the "A C function pointer cannot be formed from a closure that captures context" problem with closures:.
/// The "reference pointer" is just a pointer-sized key that is borrowed by the MIDI callback.
/// - Note: While the token type is UnsafeMutableRawPointer, they are not actually pointers and cannot be
/// safely dereferenced.
class MidiPublisherRegistry {
    class weakRef {
        weak var value: MidiNotifier?
        init(_ value: MidiNotifier) {
            self.value = value
        }
    }
    
    static var servingNext = 44556
    static var registry: [UnsafeMutableRawPointer: weakRef] = [:]

    /// Find the previously-stored notifier by its reference token.
    ///
    /// - Parameter ref: Token previously returned from a `register` call.
    /// - Returns:Publisher that was given the token during its registration.
    static func lookup(ref: UnsafeMutableRawPointer) -> MidiNotifier? {
        return registry[ref]?.value
    }

    /// Get a reference "pointer" assigned for the provided object.
    ///
    /// - Parameter publisher: The MidiNotifier to index and track.
    /// - Returns: A non-sensical token than can be "redeemed" via `lookup` to retrieve the publisher.
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
        logger.warning("Surface not found")
        return
    }
    
    for packet in packets.unsafeSequence() {
        let bytes = packet.bytes()
        if let msg = MidiMessage(bytes: bytes) {
            publisher.send(msg)
        }
    }
}
