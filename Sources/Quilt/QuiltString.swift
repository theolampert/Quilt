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
    private (set)var string: String = ""

    var attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 16),
        .foregroundColor: NSColor.white
    ]

    public var textStorage: NSTextStorage {
        let attr = NSMutableAttributedString(string: string)
        applyFormatting(attr: attr)
        return NSTextStorage(attributedString: attr)
    }


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
        self.objectWillChange.send()
    }

    private func getSpanMarkerIndex(marker: SpanMarker) -> Int {
        switch marker {
        case let .before(id):
            return quilt.appliedOps.firstIndex(where: { $0.id == id })!
        case let .after(id):
            return quilt.appliedOps.firstIndex(where: { $0.id == id })!
        }
    }

    private func applyFormatting(attr: NSMutableAttributedString) {
        for operation in quilt.appliedOps {
            switch operation.type {
            case let .addMark(type, start, end):
                switch type {
                case .bold:
                    attr.setAttributes(
                        [
                            .foregroundColor: NSColor.red
                        ],
                        range: .init(
                            location: getSpanMarkerIndex(marker: start),
                            length: getSpanMarkerIndex(marker: end)
                        )
                    )
                default:
                    print("TODO")
                }
            default:
                break
            }
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
