//
//  NSAttributedString+Extensions.swift
//  
//
//  Created by Theodore Lampert on 15.05.23.
//

import Foundation

public extension NSAttributedString {
    func safeRange(for range: NSRange) -> NSRange {
        NSRange(
            location: max(0, min(length - 1, range.location)),
            length: min(range.length, max(0, length - range.location))
        )
    }
}
