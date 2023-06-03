//
//  XTouchMiniMC.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation
import Combine
import MIDICombine
import MCSurface
import DeftLog

public typealias ControlValue = MCSurface.ControlValue

let logger = DeftLog.logger(label: "com.didactek.xtouch-mini-mc")


/// Interface to a Behringer XTouch Mini in MC (Mackie Control) mode.
/// 
/// - Note: Mackie Control mode is enabled by holding down the MC key while the device is connected to
/// USB. In MC mode, rotary encoders report relative changes, the Layer buttons do not have any built-in
/// effect, and the application is responsible for managing all "MIDI Feedback" (device indicators for button lights
/// and encoder positions).
public class XTouchMiniMC {
    let endpoint: MidiEndpoint
    var inputSubscription: AnyCancellable? = nil
    
    /// Upper row of buttons (below the encoders).
    ///
    /// - note: Buttons are mapped left to right (left-most is array head), even though the MIDI
    /// order is based on the labeled key function and is not sequential.
    public let topRowButtons: [IndicatorButton]
    /// Bottom row of buttons.
    ///
    /// - note: Buttons are mapped left to right (left-most is array head), even though the MIDI
    /// order is based on the labeled key function and is not sequential.
    public let bottomRowButtons: [IndicatorButton]
    /// Layer buttons. Indicies are 0 for "A"; 1 for "B".
    public let layerButtons: [IndicatorButton]
    /// Rotary encoders, which respond to twists of the control and can indicate position.
    ///
    /// Ordered left to right.
    /// - Note: The encode sends the same change messages whether or not the knob
    /// is depressed when turned. If you want a modal operation, you must watch the
    /// button state and manage the modal behavior yourself.
    public let encoders: [SurfaceRotaryEncoder]
    /// The analog, non-motorized fader.
    public let fader = SurfaceFader(id: 0, starting: 63)
    
    var feedbackControls: [MidiResponder] {
        // Interesting apparent compiler bug here: cannot handle all at once, but times out without other error:
        // return encoderButtons + topRowButtons + bottomRowButtons + layerButtons + encoders + [fader]
        // FIXME: is there a way these auto-register to avoid bugs when one forgets?
        let indicatorButtons = topRowButtons + bottomRowButtons + layerButtons
        return indicatorButtons + encoders + [fader]
    }
    
    public init(midiSourceIndex: Int) throws {
        let connection = try MidiCombine(sourceIndex: midiSourceIndex)
        let endpoint = connection.endpoint
        self.endpoint = endpoint
        
        self.topRowButtons = [0x59, 0x5a, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d].map {IndicatorButton(endpoint: endpoint, address: $0)}
        self.bottomRowButtons = [0x57, 0x58, 0x5b, 0x5c, 0x56, 0x5d, 0x5e, 0x5f].map {IndicatorButton(endpoint: endpoint, address: $0)}
        self.layerButtons = [0x54, 0x55].map {IndicatorButton(endpoint: endpoint, address: $0)}

        self.encoders = (0x10 ... 0x17).map {SurfaceRotaryEncoder(endpoint: endpoint, baseAddress: $0)}

        inputSubscription = connection.input.publisher.sink {
            self.notifyAllResponders(message: $0)
        }
    }
    
    /// Send message to all feedback cotrols. Each potential responder is responsible for ignoring messages
    /// it doesn't care about.
    ///
    /// There shouldn't be that many controls, and some may need to respond to multiple ids.
    func notifyAllResponders(message: MidiMessage) {
        logger.trace("Received message: subject: \(message.subject) id: \(message.id) value: \(message.value)")
        for control in feedbackControls {
            control.action(message: message)
        }
    }
}

extension SurfaceRotaryEncoder {
    /// On the XTouch Mini, the different actions of the encoder button are offset by 0x10. Convenience
    /// initializer takes  advantage of this to ensure consistency wiring functions to the same button.
    ///
    /// - note: This convention amy not apply to other controllers.
    convenience init(endpoint: MidiEndpoint, baseAddress: UInt8) {
        let delta = DeltaEncoder(address: baseAddress)
        let button = SurfaceButton(address: baseAddress + 0x10)
        let indicator = CircularIndicator(endpoint: endpoint, midiAddress: baseAddress + 0x20)
        
        self.init(delta: delta, button: button, indicator: indicator)
    }
}
