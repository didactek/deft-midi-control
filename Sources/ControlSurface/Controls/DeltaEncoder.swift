//
//  DeltaEncoder.swift
//  
//
//  Created by Kit Transue on 2020-09-16.
//

import Foundation
import Combine

public protocol DeltaEncoderProtocol {
    var change: any Publisher<Int, Never> { get }
}

public class DeltaEncoder: DeltaEncoderProtocol, SingleAddressResponder {
    var _change = PassthroughSubject<Int, Never>()
    public var change: any Publisher<Int, Never> { _change }
    
    let midiAddress: UInt8

    public init(address: UInt8) {
        midiAddress = address
    }
    
    public func action(subject: MCSubject, value: UInt8) {
        switch subject {
        case .encoderChangeMC:
            let magnitude = Int(value & 0x07)
            let clockwise = value < 0x40
            if clockwise {
                _change.send(magnitude)
            } else {
                _change.send(-magnitude)
            }
        default:
            break
        }
    }
}
