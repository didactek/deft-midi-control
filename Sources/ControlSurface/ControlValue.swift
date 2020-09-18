//
//  ControlValue.swift
//  
//
//  Created by Kit Transue on 2020-09-18.
//

import Foundation

public struct ControlValue {
    public let range: ClosedRange<Int>
    public let value: Int
    
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
    
    public func clamped(to newRange: ClosedRange<Int>) -> ControlValue {
        let newValue = Self.clamp(value: value, to: newRange)
        return ControlValue(range: newRange, value: newValue)
    }
    
    public func interpolated(as newRange: ClosedRange<Int>) -> ControlValue {
        let newValue = projected(onto: newRange)
        return ControlValue(range: newRange, value: newValue)
    }
    
    public func adjusted(by delta: Int) -> ControlValue {
        let newValue = Self.clamp(value: value + delta, to: range)
        return ControlValue(range: range, value: newValue)
    }
    
    public func changed(to value: Int) -> ControlValue {
        let newValue = Self.clamp(value: value, to: range)
        return ControlValue(range: range, value: newValue)
    }
}
