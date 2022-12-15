@testable import Quilt
import XCTest

final class QuiltTests: XCTestCase {
    func testEditing() throws {
//        var clientA = Quilt(user: UUID())
//        var clientB = Quilt(user: UUID())
//
//        let original = "The fox jumped."
//
//        clientA.set(newText: original)
//        clientB.merge(clientA)
//
//        XCTAssertEqual(original, clientA.text)
//        XCTAssertEqual(original, clientB.text)
//
//        clientA.set(newText: "The quick fox jumped.")
//        clientB.set(newText: "The fox jumped over the dog.")
//
//        clientA.merge(clientB)
//        clientB.merge(clientA)
//
//        let expected = "The quick fox jumped over the dog."
//
//        dump(clientA.operations)
//
//        XCTAssertEqual(expected, clientA.text)
//        XCTAssertEqual(expected, clientB.text)
//
//        clientA.set(newText: "The quick fox sprang over the dog.")
//        clientB.merge(clientA)
//
//        XCTAssertEqual("The quick fox sprang over the dog.", clientA.text)
//        XCTAssertEqual("The quick fox sprang over the dog.", clientB.text)
    }

    func testInsertPerformance() throws {
        /*
          `.measure {}` doesn't currently work in Swift Packages
         */
//        let startTime: CFAbsoluteTime
//        var endTime: CFAbsoluteTime?
//
//        let userID = UUID()
//        var quilt = Quilt(user: userID)
//
//        let text = """
//        Lorem ipsum dolor sit amet, consectetur adipiscing elit.
//        Integer sit amet orci id tellus ullamcorper maximus.
//        Integer luctus dui ut ornare laoreet.
//        Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
//        Quisque sed tempor eros. Fusce at malesuada tortor. Nullam et vestibulum ante.
//        Donec finibus euismod pulvinar.
//        Fusce interdum, sapien a tristique ullamcorper, sem lectus porta dolor, vel mattis libero lectus nec mi.
//        Aenean ac placerat tortor.
//        Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Duis ut lectus sit amet turpis rhoncus consectetur.
//        Mauris semper nec elit eget sagittis.
//        In maximus nisi id massa placerat tempus. Nulla viverra magna nec molestie hendrerit.
//        """
//
//        startTime = CFAbsoluteTimeGetCurrent()
//        quilt.set(newText: text)
//        endTime = CFAbsoluteTimeGetCurrent()
//        // Time elapsed: 0.36139798164367676 seconds
//        print("Time elapsed: \(endTime! - startTime) seconds")
    }
}
