//
//  XTouchMiniMC.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation
import CoreMIDI
import Combine

/// Represent a Behringer XTouch Mini in MC (Mackie Control) mode. MC is the preferred mode.
/// 
/// - Note: Mackie Control mode is enabled by holding down the MC key while the device is connected
/// to USB. In MC mode, rotary encoders are relative, the Layer buttons do not have any built-in meaning,
/// and the application is responsible for managing all "MIDI Feedback" (device indicators for button lights
/// and encoder positions).
public class XTouchMiniMC {
    let endpoint: MidiEndpoint
    var inputSubscription: AnyCancellable? = nil
    
    public let topRowButtons: [IndicatorButton]
    public let bottomRowButtons: [IndicatorButton]
    public let layerButtons: [IndicatorButton]
    public let encoders: [SurfaceRotaryEncoder]
    public let encoderButtons: [SurfaceButton]
    public let fader = SurfaceFader(id: 0, starting: 63)
    
    var feedbackControls: [SurfaceControl] {
        return topRowButtons + bottomRowButtons + layerButtons + encoders + [fader]
    }
    
    public init(sourceEndpoint: MIDIPortRef, sinkEndpoint: MIDIPortRef) throws {
        var client = MIDIClientRef()
        let clientResult = MIDIClientCreate("MIDI subsystem client" as CFString, nil, /*notifyRefCon*/nil, &client)
        guard clientResult == noErr else {
            throw ControlSurfaceError.midi("MIDIClientCreate error: \(clientResult)")
        }
        
        var outputPort = MIDIPortRef()
        let outputCreateResult = MIDIOutputPortCreate(client, "output port" as CFString, &outputPort)
        guard outputCreateResult == noErr else {
            throw ControlSurfaceError.midi("MIDIOutputPortCreate error: \(outputCreateResult)")
        }
        
        let endpoint = MidiEndpoint(port: outputPort, endpoint: sinkEndpoint)
        self.endpoint = endpoint
        
        self.topRowButtons = [0x59, 0x5a, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d].map {IndicatorButton(endpoint: endpoint, address: $0)}
        self.bottomRowButtons = [0x57, 0x58, 0x5b, 0x5c, 0x56, 0x5d, 0x5e, 0x5f].map {IndicatorButton(endpoint: endpoint, address: $0)}
        self.layerButtons = [0x54, 0x55].map {IndicatorButton(endpoint: endpoint, address: $0)}
        self.encoders = (0x10 ... 0x17).map {SurfaceRotaryEncoder(endpoint: endpoint, address: $0)}
        self.encoderButtons = (0x20 ... 0x27).map {SurfaceButton(endpoint: endpoint, address: $0)}

        let midiInput = try MidiPublisher(client: client, sourceEndpoint: sourceEndpoint)
        inputSubscription = midiInput.publisher.sink {
            self.action(message: $0)
        }
    }
    
    func action(message: MidiMessage) {
        logger.trace("Received message: subject: \(message.subject) id: \(message.id) value: \(message.value)")
        for control in feedbackControls {
            // FIXME: maybe if we're going to iterate, then maybe we should just ask each control if it cares?
            // FIXME: otherwise, a dictionary would be more efficient
            if message.id == control.midiAddress {
                control.action(message: message)
            }
        }
    }
}
