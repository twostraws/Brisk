//
//  Comparable.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

func +<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: I, rhs: F) -> F {
    return F(lhs) + rhs
}

func +<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: F, rhs: I) -> F {
    return lhs + F(rhs)
}

func -<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: I, rhs: F) -> F {
    return F(lhs) - rhs
}

func -<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: F, rhs: I) -> F {
    return lhs - F(rhs)
}

func *<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: I, rhs: F) -> F {
    return F(lhs) * rhs
}

func *<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: F, rhs: I) -> F {
    return lhs * F(rhs)
}

func /<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: I, rhs: F) -> F {
    return F(lhs) / rhs
}

func /<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: F, rhs: I) -> F {
    return lhs / F(rhs)
}

// ------------------------------------------
// How to replicate the ** operator in Swift
// 

infix operator **

func **<I: BinaryInteger>(lhs: I, rhs: I) -> I {
    return I(pow(Double(lhs), Double(rhs)))
}

func **<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: I, rhs: F) -> F {
    return F(pow(Double(lhs), Double(rhs)))
}

func **<I: BinaryInteger, F: BinaryFloatingPoint>(lhs: F, rhs: I) -> F {
    return F(pow(Double(lhs), Double(rhs)))
}

func **<F: BinaryFloatingPoint>(lhs: F, rhs: F) -> F {
    return F(pow(Double(lhs), Double(rhs)))
}
