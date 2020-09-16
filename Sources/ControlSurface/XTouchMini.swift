//
//  XTouchMini.swift
//  
//
//  Created by Kit Transue on 2020-09-15.
//

import Foundation

/// Represent a Behringer XTouch Mini in standard/layer mode.
/// - Note: In Layer mode, the device manages two states (Layer A and Layer B), which are selected
/// by the layer buttons on the right. Feedback is managed by the device. Buttons are momentary and
/// illuminate only during their press. Rotary position is reported in an absolute range 0...127 and the
/// indicators are illuminated proportionally by the device.
public class XTouchMini {
    public static let setDialPositionMessage = 0xba
}
