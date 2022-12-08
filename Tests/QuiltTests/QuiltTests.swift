import XCTest
@testable import Quilt

final class QuiltTests: XCTestCase {
    func testEditing() throws {
        var clientA = Quilt(user: UUID())
        var clientB = Quilt(user: UUID())

        let original = "The fox jumped."

        clientA.set(newText: original)
        clientB.merge(clientA)

        XCTAssertEqual(original, clientA.text)
        XCTAssertEqual(original, clientB.text)

        clientA.set(newText: "The quick fox jumped.")
        clientB.set(newText: "The fox jumped over the dog.")

        clientA.merge(clientB)
        clientB.merge(clientA)

        let expected = "The quick fox jumped over the dog."

        XCTAssertEqual(expected, clientA.text)
        XCTAssertEqual(expected, clientB.text)

        clientA.set(newText: "The quick fox sprang over the dog.")
        clientB.merge(clientA)

        XCTAssertEqual("The quick fox sprang over the dog.", clientA.text)
        XCTAssertEqual("The quick fox sprang over the dog.", clientB.text)
    }

    func testInsertPerformance() throws {
        let startTime: CFAbsoluteTime
        var endTime: CFAbsoluteTime?

        let userID = UUID()
        var quilt = Quilt(user: userID)

        let text = """
        Nullam vel massa egestas nulla fringilla faucibus in nec orci.
        Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.
        Vestibulum tellus erat, mollis vitae malesuada ac, euismod tincidunt arcu.
        Vestibulum ut rhoncus lacus, id vehicula neque. Quisque vel erat dapibus, fringilla magna in, fringilla magna.
        """

        startTime = CFAbsoluteTimeGetCurrent()
        quilt.set(newText: text)
        endTime = CFAbsoluteTimeGetCurrent()
        // Time elapsed: 3.7783960103988647 seconds
        print("Time elapsed: \(endTime! - startTime) seconds")
    }
}
