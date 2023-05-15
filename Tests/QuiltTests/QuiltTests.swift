//
//  QuiltTests.swift
//
//
//  Created by Theodore Lampert on 29.01.23.
//

@testable import Quilt
import XCTest

final class QuiltTests: XCTestCase {
    let user = UUID(uuidString: "E2DFDB75-A3D9-4B55-9312-111EF297D566")!

    func testAddRemoveOps() throws {
        var quilt = Quilt(user: user)

        quilt.insert(character: "T", atIndex: 0)

        XCTAssertEqual(
            quilt.operations[0],
            Operation(
                opId: OpID(counter: 0, id: user),
                type: .insert("T"),
                afterId: nil
            )
        )

        quilt.insert(character: "H", atIndex: 1)

        XCTAssertEqual(
            quilt.operations[1],
            Operation(
                opId: OpID(counter: 1, id: user),
                type: .insert("H"),
                afterId: quilt.operations[0].id
            )
        )

        quilt.remove(atIndex: 1)

        XCTAssertEqual(
            quilt.operations[2],
            Operation(
                opId: OpID(counter: 2, id: user),
                type: .remove(quilt.operations[1].id)
            )
        )
    }

    func testAddRemoveMarkOps() throws {
        var quilt = Quilt(user: user)
        quilt.insert(character: "H", atIndex: 0)
        quilt.insert(character: "e", atIndex: 1)
        quilt.insert(character: "l", atIndex: 2)
        quilt.insert(character: "l", atIndex: 3)
        quilt.insert(character: "o", atIndex: 4)

        quilt.addMark(mark: .bold, fromIndex: 0, toIndex: 4)

        XCTAssertEqual(quilt.operations[5], Operation(
            opId: OpID(counter: 5, id: user),
            type: .addMark(
                type: .bold,
                start: .before(OpID(counter: 0, id: user)),
                end: .before(OpID(counter: 4, id: user))
            )
        ))

        quilt.removeMark(
            mark: .bold,
            fromIndex: 0,
            toIndex: 4
        )

        XCTAssertEqual(quilt.operations[6], Operation(
            opId: OpID(counter: 6, id: user),
            type: .removeMark(
                type: .bold,
                start: .before(OpID(counter: 0, id: user)),
                end: .before(OpID(counter: 4, id: user))
            )
        ))
    }
}
