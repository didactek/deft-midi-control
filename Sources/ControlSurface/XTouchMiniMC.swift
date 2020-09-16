//
//  XTouchMiniMC.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation
import CoreMIDI

/// Represent a Behringer XTouch Mini in MC (Mackie Control) mode. MC is the preferred mode.
/// 
/// - Note: Mackie Control mode is enabled by holding down the MC key while the device is connected
/// to USB. In MC mode, rotary encoders are relative, the Layer buttons do not have any built-in meaning,
/// and the application is responsible for managing all "MIDI Feedback" (device indicators for button lights
/// and encoder positions).
public class XTouchMiniMC {
    var controlPort: MIDIPortRef
    var controlEndpoint: MIDIEndpointRef
    
    let recAddress = UInt8(0x5f)
    let recButton = SurfaceButton(address: 0x5f, mode: .toggle)
    
    public init(sourceEndpoint: MIDIPortRef, sinkEndpoint: MIDIPortRef) {
        /// aka: refCon in MIDIInputPortCreate
        let readProcRefCon: UnsafeMutableRawPointer? = XTRegistry.newRefPtr()
        /// aka: connRefCon in MIDIPortConnectSource
        let srcConnRefCon: UnsafeMutableRawPointer? = nil
        let notifyRefCon: UnsafeMutableRawPointer? = nil
        
        var client = MIDIClientRef()
        let clientResult = MIDIClientCreate("MIDI subsystem client" as CFString, nil, notifyRefCon, &client)
        guard clientResult == noErr else {
            fatalError("MIDIClientCreate error: \(clientResult)")
        }
        
        var inputPort = MIDIPortRef()
        let portResult = MIDIInputPortCreate(client, "input port" as CFString, midiEventCallback, readProcRefCon, &inputPort)
        guard portResult == noErr else {
            fatalError("MIDIInputPortCreate error: \(portResult)")
        }
        
        let bindResult = MIDIPortConnectSource(inputPort, sourceEndpoint, srcConnRefCon)
        guard bindResult == noErr else {
            fatalError("MIDIPortConnectSource error: \(bindResult)")
        }
        
        var outputPort = MIDIPortRef()
        let outputCreateResult = MIDIOutputPortCreate(client, "output port" as CFString, &outputPort)
        guard outputCreateResult == noErr else {
            fatalError("MIDIOutputPortCreate error: \(outputCreateResult)")
        }
        
        self.controlPort = outputPort
        self.controlEndpoint = sinkEndpoint
        XTRegistry.register(fakePtr: readProcRefCon!, surface: self)
    }
    
    func action(message: MidiMessage) {
        debugPrint(message)
        if message.id == recAddress {
            recButton.action(message: message)
            sendMidi(message: recButton.feedback())
        }
    }
    
    func sendMidi(message: MidiMessage) {
        let midiNow: MIDITimeStamp = 0
        
        let builder = MIDIPacket.Builder(maximumNumberMIDIBytes: 3)
        print("sending message \(message.subject), \(message.id) value \(message.value)")
        builder.append(message.subject.rawValue, message.id, message.value)
        builder.timeStamp = /*bug in Builder.timeStamp signature*/ Int(midiNow)
        
        builder.withUnsafePointer { packet in
            var list = MIDIPacketList()
            list.numPackets = 1
            list.packet = packet.pointee
            MIDISend(controlPort, controlEndpoint, &list)
        }
    }
}

class XTRegistry {
    class weakRef {
        weak var value: XTouchMiniMC?
        init(_ value: XTouchMiniMC) {
            self.value = value
        }
    }
    
    static var servingNext = 44556
    static var registry: [UnsafeMutableRawPointer: weakRef] = [:]
    static func lookup(ref: UnsafeMutableRawPointer) -> XTouchMiniMC? {
        return registry[ref]?.value
    }
    static func newRefPtr() -> UnsafeMutableRawPointer {
        servingNext += 1
        let fakePtr = UnsafeMutableRawPointer(bitPattern: servingNext)!
        return fakePtr
    }
    static func register(fakePtr: UnsafeMutableRawPointer, surface: XTouchMiniMC) {
        registry[fakePtr] = weakRef(surface)
    }
}

func midiEventCallback(_ packets: UnsafePointer<MIDIPacketList>, _ readProcRefCon: UnsafeMutableRawPointer?, _ srcConnRefCon: UnsafeMutableRawPointer?) {
    // FIXME: make lookup more optional-friendly
    guard let surface = XTRegistry.lookup(ref: readProcRefCon!) else {
        print("Surface not found")
        return
    }
    
    for packet in packets.unsafeSequence() {
        let bytes = packet.bytes()
        if let msg = MidiMessage(bytes: bytes) {
            surface.action(message: msg)
        }
    }
}
