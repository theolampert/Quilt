//
//  File.swift
//
//
//  Created by Theodore Lampert on 15.12.22.
//

import Foundation
import AppKit

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
            return quilt.appliedOps.firstIndex(where: { $0.id == id })!
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

public extension NSAttributedString {
    func textAttribute<Value>(_ key: Key, at range: NSRange) -> Value? {
        textAttributes(at: range)[key] as? Value
    }

    func textAttributes(at range: NSRange) -> [Key: Any] {
        if length == 0 { return [:] }
        let range = safeRange(for: range)
        return attributes(at: range.location, effectiveRange: nil)
    }
}

public extension NSMutableAttributedString {
    func setTextAttribute(_ key: Key, to newValue: Any, at range: NSRange) {
        let range = safeRange(for: range)
        guard length > 0, range.location >= 0 else { return }
        beginEditing()
        enumerateAttribute(key, in: range, options: .init()) { value, range, _ in
            removeAttribute(key, range: range)
            addAttribute(key, value: newValue, range: range)
            fixAttributes(in: range)
        }
        endEditing()
    }
}

extension QuiltString {
    public var attString: NSMutableAttributedString {
        let attString = NSMutableAttributedString(string: string)
        return appleFormatting(string: attString)
    }

    private func appleFormatting(string: NSMutableAttributedString) -> NSMutableAttributedString {
        for operation in quilt.appliedOps {
            switch operation.type {
            case let .addMark(type, start, end):
                switch type {
                case .underline:
                    string.setTextAttribute(
                        .underlineStyle, to: true, at: NSRange(
                            location: getSpanMarkerIndex(marker: start) - 1,
                            length: getSpanMarkerIndex(marker: end)
                        )
                    )

                case .bold:
                    return string
                case .italic:
                    return string
                }
            default:
                return string
            }
        }
        return string
    }
}
