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
    let endpoint: MidiEndpoint
//    public let controlPort: MIDIPortRef
//    public let controlEndpoint: MIDIEndpointRef
    
    let topRowButtons: [SurfaceButton]
    let bottomRowButtons: [SurfaceButton]
    let layerButtons: [SurfaceButton]
    let encoders: [SurfaceRotaryEncoder]
    
    var feedbackControls: [SurfaceControl] {
        return topRowButtons + bottomRowButtons + layerButtons + encoders
    }
    
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
        
        let endpoint = MidiEndpoint(port: outputPort, endpoint: sinkEndpoint)
        self.endpoint = endpoint
        
        self.topRowButtons = [0x59, 0x5a, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d].map {SurfaceButton(endpoint: endpoint, address: $0)}
        self.bottomRowButtons = [0x57, 0x58, 0x5b, 0x5c, 0x56, 0x5d, 0x5e, 0x5f].map {SurfaceButton(endpoint: endpoint, address: $0)}
        self.layerButtons = [0x54, 0x55].map {SurfaceButton(endpoint: endpoint, address: $0)}
        self.encoders = (0x10 ... 0x17).map {SurfaceRotaryEncoder(endpoint: endpoint, address: $0)}
        
        XTRegistry.register(fakePtr: readProcRefCon!, surface: self)
    }
    
    func action(message: MidiMessage) {
        debugPrint(message)
        for control in feedbackControls {
            // FIXME: maybe if we're going to iterate, then maybe we should just ask each control if it cares?
            // FIXME: otherwise, a dictionary would be more efficient
            if message.id == control.midiAddress {
                control.action(message: message)
                endpoint.sendMidi(message: control.feedback())
            }
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
