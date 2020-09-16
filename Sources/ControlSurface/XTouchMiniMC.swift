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
        var client = MIDIClientRef()
        let clientResult = MIDIClientCreate("MIDI subsystem client" as CFString, nil, nil, &client)
        guard clientResult == noErr else {
            fatalError("MIDIClientCreate error: \(clientResult)")
        }
        
        var inputPort = MIDIPortRef()
        let portResult = MIDIInputPortCreate(client, "input port" as CFString, midiEventCallback, nil, &inputPort)
        guard portResult == noErr else {
            fatalError("MIDIInputPortCreate error: \(portResult)")
        }
        
        let bindResult = MIDIPortConnectSource(inputPort, sourceEndpoint, nil)
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

// FIXME: why can't I make this a static member of class?
func midiEventCallback(_ packets: UnsafePointer<MIDIPacketList>, _ readProcRefCon: UnsafeMutableRawPointer?, _ srcConnRefCon: UnsafeMutableRawPointer?) {
}
