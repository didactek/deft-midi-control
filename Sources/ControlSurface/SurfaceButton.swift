//
//  SurfaceButton.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation

public class SurfaceButton {
    enum Mode {
        case momentary
        case toggle
    }

    let midiAddress: UInt8
    
    var selected: Bool = false
    var mode: Mode = .momentary
    
    public init(address: Int) {
        midiAddress = UInt8(address)
    }
}
