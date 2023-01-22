//
//  QuiltSwiftUI.swift
//
//
//  Created by Theodore Lampert on 15.12.22.
//

import SwiftUI

public class QuiltTextStorage: NSTextStorage, ObservableObject {
    public init(quilt: Quilt) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 16),
            .foregroundColor: NSColor.white
        ]
        self.quilt = quilt
        self.attributes = attributes
        self.attributedString = .init(string: "", attributes: attributes)
        super.init()
    }

    @Published
    public var attributedString: NSMutableAttributedString

    var attributes: [NSAttributedString.Key: Any]

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        fatalError("init(pasteboardPropertyList:ofType:) has not been implemented")
    }

    public private(set) var quilt: Quilt

    public override var string: String {
        return attributedString.string
    }

    public override func didChange(
        _ changeKind: NSKeyValueChange,
        valuesAt indexes: IndexSet,
        forKey key: String
    ) {
//        print(changeKind, indexes, key)
    }

    public override func attributes(
      at location: Int,
      effectiveRange range: NSRangePointer?
    ) -> [NSAttributedString.Key: Any] {
        return attributes
    }

    public override func replaceCharacters(
        in range: NSRange,
        with string: String
    ) {
        beginEditing()
//        attributedString.replaceCharacters(in: range, with:string)
        edited(.editedCharacters, range: range,
               changeInLength: (string as NSString).length - range.length)
        if range.upperBound == range.lowerBound {
            self.insert(character: string, atIndex: range.lowerBound)
        } else {
            for idx in range.lowerBound..<range.upperBound {
                if string.isEmpty {
                    self.remove(atIndex: idx)
                } else {
                    self.insert(
                        character: string,
                        atIndex: idx
                    )
                }
            }
        }
        endEditing()
    }

    public override func setAttributes(
        _ attrs: [NSAttributedString.Key: Any]?,
        range: NSRange
    ) {
        beginEditing()
//        attributedString.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

}

public extension QuiltTextStorage {
    func insert(character: String, atIndex: Int) {
        quilt.insert(character: character, atIndex: atIndex)
        createText()
    }

    func remove(atIndex: Int) {
        quilt.remove(atIndex: atIndex)
        createText()
    }

    func addMark(mark: MarkType, fromIndex: Int, toIndex: Int) {
        quilt.addMark(mark: mark, fromIndex: fromIndex, toIndex: toIndex)
        appleFormatting()
    }

    private func getSpanMarkerIndex(marker: SpanMarker) -> Int {
        switch marker {
        case let .before(id):
            return quilt.appliedOps.firstIndex(where: { $0.id == id })!
        case let .after(id):
            return quilt.appliedOps.firstIndex(where: { $0.id == id })!
        }
    }

    private func appleFormatting() {
        for operation in quilt.appliedOps {
            switch operation.type {
            case let .addMark(type, start, end):
                switch type {
                case .bold:
                    attributedString.beginEditing()
                    attributedString.setAttributes(
                        [
                            .foregroundColor: NSColor.red
//                            .font: Font.system(size: 90, weight: .black)
                        ],
                        range: .init(
                            location: 0,
                            length: attributedString.length
                        )
                    )
                    attributedString.endEditing()
                default:
                    print("TODO")
                }
            default:
                break
            }
        }
//        print(attributedString, attributedString.length)
    }

    private func createText() {
        let newString = NSMutableAttributedString(string: "", attributes: attributes)

        for operation in quilt.appliedOps {
            switch operation.type {
            case let .insert(character):
                let attr = NSMutableAttributedString(string: character, attributes: attributes)
                newString.append(attr)
            case let .remove(removeID):
                print("TODO")
            case let .removeMark(removeAt):
                print("TODO REMOVE MARK \(removeAt)")
            default:
                break
            }
        }
        attributedString = newString
    }
}
