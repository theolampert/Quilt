//
//  File.swift
//
//
//  Created by Theodore Lampert on 15.12.22.
//

import Foundation
import AppKit
import SwiftUI

public class QuiltString: ObservableObject {
    public init(
        quilt: Quilt = .init(user: UUID()),
        string: String = ""
    ) {
        self.quilt = quilt
        self.string = string
    }

    public var quilt: Quilt = .init(user: UUID())

    @Published
    public var string: String = ""

    public func insert(character: String, atIndex: Int) {
        quilt.insert(character: character, atIndex: atIndex)
        createText()
    }

    public func remove(atIndex: Int) {
        quilt.remove(atIndex: atIndex)
        createText()
    }

    public func addMark(mark: MarkType, fromIndex: Int, toIndex: Int) {
        quilt.addMark(mark: mark, fromIndex: fromIndex, toIndex: toIndex)
        createText()
    }

    private func getSpanMarkerIndex(marker: SpanMarker) -> Int {
        switch marker {
        case let .before(id):
            return quilt.appliedOps.firstIndex(where: { $0.id == id }) ?? 0
        case let .after(id):
            return quilt.appliedOps.firstIndex(where: { $0.id == id })!
        }
    }

    private func createText() {
        string = quilt
            .appliedOps
            .reduce("") { acc, curr in
                switch curr.type {
                case let .insert(character):
                    return acc + character
                default:
                    return acc
                }
            }
    }

    public func set(newText: String) {
        for change in newText.difference(from: string) {
            switch change {
            case let .insert(offset, element, _):
                insert(character: String(element), atIndex: offset)
            case let .remove(offset, _, _):
                remove(atIndex: offset)
            }
        }
    }

    public func merge(_ peritext: Quilt) {
        quilt.merge(peritext)
        createText()
    }
}

public extension NSAttributedString {
    func safeRange(for range: NSRange) -> NSRange {
        NSRange(
            location: max(0, min(length-1, range.location)),
            length: min(range.length, max(0, length - range.location)))
    }
}

public extension NSMutableAttributedString {
    func setTextAttribute(_ key: Key, to newValue: Any, at range: NSRange) {
        let range = safeRange(for: range)
        guard length > 0, range.location >= 0 else { return }
        beginEditing()
        enumerateAttribute(key, in: range, options: .init()) { value, range, _ in
            addAttribute(key, value: newValue, range: range)
            fixAttributes(in: range)
        }
        endEditing()
    }
}

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
            if case .addMark(let type, let start, let end) = operation.type {
                switch type {
                case .underline, .bold, .italic:
                    string.setTextAttribute(
                        .underlineStyle, to: true, at: NSRange(
                            location: getSpanMarkerIndex(marker: start),
                            length: getSpanMarkerIndex(marker: end) + 1
                        )
                    )
                }
            }
        }

        return string
    }
}
