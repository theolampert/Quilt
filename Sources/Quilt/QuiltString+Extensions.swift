//
//  QuiltString.swift
//
//
//  Created by Theodore Lampert on 15.05.23.
//

import AppKit
import Foundation

extension QuiltString {
    public var attString: NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: string)
        let fontBase = NSFont.systemFont(ofSize: 16)
        attString.setTextAttribute(
            .font, to: fontBase, at: NSRange(location: 0, length: string.count)
        )
        return applyFormatting(string: attString)
    }

    private func applyFormatting(string: NSMutableAttributedString) -> NSMutableAttributedString {
        for operation in quilt.operations {
            if case let .addMark(type, start, end) = operation.type {
                switch type {
                case .underline:
                    string.setTextAttribute(
                        .underlineStyle, to: true, at: NSRange(
                            location: getSpanMarkerIndex(marker: start),
                            length: getSpanMarkerIndex(marker: end) + 1
                        )
                    )
                case .bold:
                    print("TODO bold")
                case .italic:
                    print("TODO italic")
                }
            }
        }

        return string
    }
}
