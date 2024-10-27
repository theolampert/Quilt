//
//  QuiltTests.swift
//
//
//  Created by Theodore Lampert on 29.01.23.
//

import Foundation
import Testing
@testable import Quilt
import XCTest

let user = UUID(uuidString: "E2DFDB75-A3D9-4B55-9312-111EF297D566")!
let otherUser = UUID(uuidString: "F3DFDB75-A3D9-4B55-9312-111EF297D567")!


@Test func testAddRemoveOps() throws {
    var quilt = Quilt(user: user)

    quilt.insert(character: "T", atIndex: 0)

    XCTAssertEqual(
        quilt.operationLog[0],
        Operation(
            opId: OpID(counter: 0, id: user),
            type: .insert("T"),
            afterId: nil
        )
    )

    quilt.insert(character: "H", atIndex: 1)

    XCTAssertEqual(
        quilt.operationLog[1],
        Operation(
            opId: OpID(counter: 1, id: user),
            type: .insert("H"),
            afterId: quilt.operationLog[0].id
        )
    )

    quilt.remove(atIndex: 1)

    XCTAssertEqual(
        quilt.operationLog[2],
        Operation(
            opId: OpID(counter: 2, id: user),
            type: .remove(quilt.operationLog[1].id)
        )
    )
}

@Test func testAddRemoveMarkOps() throws {
    var quilt = Quilt(user: user)
    quilt.insert(character: "H", atIndex: 0)
    quilt.insert(character: "e", atIndex: 1)
    quilt.insert(character: "l", atIndex: 2)
    quilt.insert(character: "l", atIndex: 3)
    quilt.insert(character: "o", atIndex: 4)

    quilt.addMark(mark: .bold, fromIndex: 0, toIndex: 4)

    XCTAssertEqual(quilt.operationLog[5], Operation(
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

    XCTAssertEqual(quilt.operationLog[6], Operation(
        opId: OpID(counter: 6, id: user),
        type: .removeMark(
            type: .bold,
            start: .before(OpID(counter: 0, id: user)),
            end: .before(OpID(counter: 4, id: user))
        )
    ))
}

@Test func testArraySafeIndex() {
    let array = [1, 2, 3]

    XCTAssertEqual(array[safeIndex: 0], 1)
    XCTAssertEqual(array[safeIndex: 2], 3)
    XCTAssertNil(array[safeIndex: -1])
    XCTAssertNil(array[safeIndex: 3])
}

// MARK: - OpID Tests

@Test func testOpIDComparison() {
    let id1 = OpID(counter: 1, id: user)
    let id2 = OpID(counter: 2, id: user)
    let id3 = OpID(counter: 2, id: otherUser)

    XCTAssertLessThan(id1, id2)
    XCTAssertGreaterThan(id2, id1)

    // Test same counter, different UUIDs
    XCTAssertNotEqual(id2, id3)
    // Since user UUID < otherUser UUID
    XCTAssertLessThan(id2, id3)
}

@Test func testOpIDDescription() {
    let id = OpID(counter: 42, id: user)
    XCTAssertEqual(id.description, "42@\(user)")
}

// MARK: - Quilt Merge Tests

@Test func testMergeQuilt() {
    var quilt1 = Quilt(user: user)
    var quilt2 = Quilt(user: otherUser)

    quilt1.insert(character: "A", atIndex: 0)
    quilt2.insert(character: "B", atIndex: 0)

    quilt1.merge(quilt2)

    XCTAssertEqual(quilt1.operationLog.count, 2)
    XCTAssertEqual(quilt1.currentContent.count, 2)
}

@Test func testMergeDuplicateOperations() {
    var quilt1 = Quilt(user: user)
    var quilt2 = Quilt(user: otherUser)  // Changed to different user

    quilt1.insert(character: "A", atIndex: 0)
    quilt2.operationLog = quilt1.operationLog
    quilt2.insert(character: "B", atIndex: 1)

    quilt1.merge(quilt2)

    // Should add both operationLog since they're from different users
    XCTAssertEqual(quilt1.operationLog.count, 2)
    XCTAssertEqual(quilt1.currentContent.count, 2)
}

// MARK: - Edge Cases Tests

@Test func testRemoveFromEmptyQuilt() {
    var quilt = Quilt(user: user)

    // Should not crash
    quilt.remove(atIndex: 0)
    XCTAssertEqual(quilt.operationLog.count, 0)
}

@Test func testRemoveFromInvalidIndex() {
    var quilt = Quilt(user: user)
    quilt.insert(character: "A", atIndex: 0)

    // Should not crash and should add the remove operation
    quilt.remove(atIndex: 1)
    XCTAssertEqual(quilt.operationLog.count, 2)
}

@Test func testInsertAtInvalidIndex() {
    var quilt = Quilt(user: user)

    // Should still work by inserting at the end
    quilt.insert(character: "A", atIndex: 999)
    XCTAssertEqual(quilt.operationLog.count, 1)
}
