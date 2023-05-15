//
//  File.swift
//
//
//  Created by Theodore Lampert on 15.12.22.
//

import AppKit
import Foundation
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

    internal func getSpanMarkerIndex(marker: SpanMarker) -> Int {
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
