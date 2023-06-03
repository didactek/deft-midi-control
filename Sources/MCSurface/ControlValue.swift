//
//  ControlValue.swift
//  
//
//  Created by Kit Transue on 2020-09-18.
//  Copyright © 2020 Kit Transue
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// Model a control's setting as a value within a closed range.
public struct ControlValue {
    public let range: ClosedRange<Int>
    public let value: Int
    
    public init(range: ClosedRange<Int>, value: Int) {
        self.range = range
        self.value = value
    }
    
    private func projected(onto newRange: ClosedRange<Int>) -> Int {
        // This is not a simple linear interpolation because we want the values
        // to be evenly divided if requested range is smaller than internal range.
        let slope = Double(newRange.count) / Double(range.count)
        let deltaX = Double(value - range.lowerBound)
        let deltaY = deltaX * slope
        return newRange.lowerBound + Int(deltaY)
    }
    
    static func clamp(value: Int, to range: ClosedRange<Int>) -> Int {
        let clampedValue: Int
        if value < range.lowerBound {
            clampedValue = range.lowerBound
        }
        else if value > range.upperBound {
            clampedValue = range.upperBound
        }
        else {
            clampedValue = value
        }
        return clampedValue
    }
    
    /// Change the range used by a control, keeping its existing value if it still fits in the new range,
    /// or selecting the closest value to the old that is within the new range.
    public func clamped(to newRange: ClosedRange<Int>) -> ControlValue {
        let newValue = Self.clamp(value: value, to: newRange)
        return ControlValue(range: newRange, value: newValue)
    }
    
    /// Change the range of a control and adjust its current value
    public func interpolated(as newRange: ClosedRange<Int>) -> ControlValue {
        let newValue = projected(onto: newRange)
        return ControlValue(range: newRange, value: newValue)
    }
    
    /// Get a new value by adding the provided ticks to the underlying range.
    public func adjusted(by delta: Int) -> ControlValue {
        let newValue = Self.clamp(value: value + delta, to: range)
        return ControlValue(range: range, value: newValue)
    }
    
    public func changed(to value: Int) -> ControlValue {
        let newValue = Self.clamp(value: value, to: range)
        return ControlValue(range: range, value: newValue)
    }
    
    /// Return a value 0.0 ... 1.0
    public func normalized() -> Double {
        return Double(value - range.lowerBound) / Double(range.count - 1)
    }
    
    public func changed(toNormalized value: Double) -> ControlValue {
        let newValue = Self.clamp(value: Int(value * Double(range.count)) - range.lowerBound, to: range)
        return ControlValue(range: range, value: newValue)
    }
}
