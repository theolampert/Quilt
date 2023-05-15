//
//  NSMutableAttributedString+setTextAttribute.swift
//  
//
//  Created by Theodore Lampert on 15.05.23.
//

import Foundation

public extension NSMutableAttributedString {
    func setTextAttribute(_ key: Key, to newValue: Any, at range: NSRange) {
        let range = safeRange(for: range)
        guard length > 0, range.location >= 0 else { return }
        beginEditing()
        enumerateAttribute(key, in: range, options: .init()) { _, range, _ in
            addAttribute(key, value: newValue, range: range)
            fixAttributes(in: range)
        }
        endEditing()
    }
}
