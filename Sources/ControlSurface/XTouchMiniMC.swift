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
    
    public init(sourceEndpoint: MIDIPortRef, sinkEndpoint: MIDIPortRef) {
        /// aka: refCon in MIDIInputPortCreate
        let readProcRefCon: UnsafeMutableRawPointer? = nil
        /// aka: connRefCon in MIDIPortConnectSource
        let srcConnRefCon: UnsafeMutableRawPointer? = nil
        let notifyRefCon: UnsafeMutableRawPointer? = UnsafeMutableRawPointer(bitPattern: 45)

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
    static func register(surface: XTouchMiniMC) -> UnsafeMutableRawPointer {
        servingNext += 1
        let fakePtr = UnsafeMutableRawPointer(bitPattern: servingNext)!
        registry[fakePtr] = weakRef(surface)
        return fakePtr
    }
}

// FIXME: why can't I make this a static member of class?
// FIXME: could implement this via a closuer & get capture...
// "A C function pointer cannot be formed from a closure that captures context"
func midiEventCallback(_ packets: UnsafePointer<MIDIPacketList>, _ readProcRefCon: UnsafeMutableRawPointer?, _ srcConnRefCon: UnsafeMutableRawPointer?) {
}
