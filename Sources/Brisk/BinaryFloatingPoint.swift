//
//  BinaryFloatingPoint.swift
//  Terminal
//
//  Created by Paul Hudson on 20/02/2020.
//  Copyright © 2020 Hacking with Swift. All rights reserved.
//

import Foundation

extension BinaryFloatingPoint {
    /// e
    public static var e: Self { 2.71828182845904523536028747135266250 }

    /// log2(e)
    public static var log2e: Self { 1.44269504088896340735992468100189214 }

    /// log10(e)
    public static var log10e: Self { 0.434294481903251827651128918916605082 }

    /// loge(2)
    public static var ln2: Self { 0.693147180559945309417232121458176568 }

    /// loge(10)
    public static var ln10: Self { 2.30258509299404568401799145468436421 }

    /// pi/2
    public static var pi2: Self { 1.57079632679489661923132169163975144 }

    /// pi/4
    public static var pi4: Self { 0.785398163397448309615660845819875721 }

    /// sqrt(2)
    public static var sqrt2: Self { 1.41421356237309504880168872420969808 }

    /// 1/sqrt(2)
    public static var sqrt1_2: Self { 0.707106781186547524400844362104849039 }
}
