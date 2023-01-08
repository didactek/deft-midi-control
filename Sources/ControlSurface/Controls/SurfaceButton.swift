//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2023-01-06.
//

import Foundation
import Combine

public class SurfaceButton: MidiResponder, MomentaryButton, SingleAddressResponder {
    let midiAddress: UInt8
    
    let _isPressed = PassthroughSubject<Bool, Never>()
    public var isPressed: any Publisher<Bool, Never> { _isPressed }
    
    init(address: UInt8) {
        self.midiAddress = address
    }

    public func action(subject: MCSubject, value: UInt8) {
        guard subject == .buttonMC else {
            logger.warning("button got unexpected action \(subject)")
            return
        }
        _isPressed.send(value != 0)
    }
}
