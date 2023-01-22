@testable import Quilt
import XCTest

final class QuiltTests: XCTestCase {
    func testEditing() throws {
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

        clientA.addMark(mark: .bold, fromIndex: 0, toIndex: 10)

        print(clientA.textStorage)

        XCTAssertEqual("The quick fox sprang over the dog.", clientA.string)
        XCTAssertEqual("The quick fox sprang over the dog.", clientB.string)
    }
}
