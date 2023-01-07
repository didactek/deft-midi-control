//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2023-01-06.
//

import Foundation

public class SurfaceButton: MidiResponder, MomentaryButton, SingleAddressResponder {
    let midiAddress: UInt8
    
    @Published
    public private(set) var isPressed = false
    
    init(address: UInt8) {
        self.midiAddress = address
    }

    public func action(subject: MidiSubject, value: UInt8) {
        guard subject == .buttonMC else {
            logger.warning("button got unexpected action \(subject)")
            return
        }
        isPressed = value != 0
    }
}
