//
//  MomentaryButton.swift
//  
//
//  Created by Kit Transue on 2023-01-06.
//

import Foundation

/// A button in Mackie mode.
///
/// Button reports a state change once when it is pressed and another time when it is released.
public protocol MomentaryButton {
    var isPressed: Bool {get}
}
