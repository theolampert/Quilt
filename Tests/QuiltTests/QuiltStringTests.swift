@testable import Quilt
import XCTest

final class QuiltStringTests: XCTestCase {
    func testOpIDGreater() throws {
        let userA = UUID()
        let userB = UUID()

        let opIDA = OpID(counter: 0, id: userA)
        let opIDB = OpID(counter: 1, id: userB)

        XCTAssertTrue(opIDA < opIDB)
    }

    func testOpIDEqual() throws {
        let userA = UUID(uuidString: "E2DFDB75-A3D9-4B55-9312-111EF297D566")!
        let userB = UUID(uuidString: "D777AB4C-54BF-4381-9051-DA1945F9686C")!

        let opIDA = OpID(counter: 0, id: userA)
        let opIDB = OpID(counter: 0, id: userB)

        XCTAssertTrue(opIDA > opIDB)
    }

    func testEditMerging() throws {
        let clientA = QuiltString()
        let clientB = QuiltString()

        let original = "The fox jumped."

        clientA.set(newText: original)
        clientB.merge(clientA.quilt)

        XCTAssertEqual(original, clientA.string)
        XCTAssertEqual(original, clientB.string)

        clientA.set(newText: "The quick fox jumped.")
        clientB.set(newText: "The fox jumped over the dog.")

        clientA.merge(clientB.quilt)
        clientB.merge(clientA.quilt)

        let expected = "The quick fox jumped over the dog."

        XCTAssertEqual(expected, clientA.string)
        XCTAssertEqual(expected, clientB.string)

        clientA.set(newText: "The quick fox sprang over the dog.")
        clientB.merge(clientA.quilt)

        XCTAssertEqual("The quick fox sprang over the dog.", clientA.string)
        XCTAssertEqual("The quick fox sprang over the dog.", clientB.string)
    }

    func testUnderlineAttributedString() throws {
        let clientA = QuiltString()

        clientA.set(newText: "Hello World")
        clientA.addMark(mark: .underline, fromIndex: 0, toIndex: 10)

        let exptected = NSMutableAttributedString("Hello World")
        exptected.setTextAttribute(
            .underlineStyle, to: true, at: NSRange(location: 0, length: 11)
        )
        let fontBase = NSFont.systemFont(ofSize: 16)
        exptected.setTextAttribute(
            .font, to: fontBase, at: NSRange(location: 0, length: 11)
        )
        XCTAssertTrue(clientA.attString.isEqual(to: exptected))
    }

    func testRemoveUnderlineAttributedString() throws {
//        let clientA = QuiltString()
//
//        clientA.set(newText: "Hello World")
//        clientA.addMark(mark: .underline, fromIndex: 6, toIndex: 10)
//
//        let exptected = NSMutableAttributedString("Hello World")
//
//        clientA.set(newText: "Hello ")
//
//        XCTAssertTrue(clientA.attString.isEqual(to: exptected))
    }

    func testBoldAttributedString() throws {
        let clientA = QuiltString()

        clientA.set(newText: "Hello World")
        clientA.addMark(mark: .bold, fromIndex: 0, toIndex: 10)

        let exptected = NSMutableAttributedString("Hello World")
//        exptected.setTextAttribute(
//            .underlineStyle, to: true, at: NSRange(location: 0, length: 11)
//        )
//        print(clientA.attString)
//        XCTAssertTrue(clientA.attString.isEqual(to: exptected))
    }

    func testItalicAttributedString() throws {
        let clientA = QuiltString()

        clientA.set(newText: "Hello World")
        clientA.addMark(mark: .italic, fromIndex: 0, toIndex: 10)

        let exptected = NSMutableAttributedString("Hello World")
//        exptected.setTextAttribute(
//            .underlineStyle, to: true, at: NSRange(location: 0, length: 11)
//        )

//        print(clientA.attString)
//        XCTAssertTrue(clientA.attString.isEqual(to: exptected))
    }
}
