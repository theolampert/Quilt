//
//  QuiltTests.swift
//
//
//  Created by Theodore Lampert on 29.01.23.
//

import Foundation
import Testing
@testable import Quilt

let user = UUID(uuidString: "E2DFDB75-A3D9-4B55-9312-111EF297D566")!
let otherUser = UUID(uuidString: "F3DFDB75-A3D9-4B55-9312-111EF297D567")!

@Test func testAddRemoveOps() throws {
    var quilt = Quilt(user: user)

    quilt.insert(character: "T", atIndex: 0)

    #expect(
        quilt.operationLog[0] == Operation(
            opId: OpID(counter: 0, id: user),
            type: .insert("T"),
            afterId: nil
        )
    )

    quilt.insert(character: "H", atIndex: 1)

    #expect(
        quilt.operationLog[1] == Operation(
            opId: OpID(counter: 1, id: user),
            type: .insert("H"),
            afterId: quilt.operationLog[0].id
        )
    )

    quilt.remove(atIndex: 1)

    #expect(
        quilt.operationLog[2] == Operation(
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

    #expect(quilt.operationLog[5] == Operation(
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

    #expect(quilt.operationLog[6] == Operation(
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

    #expect(array[safeIndex: 0] == 1)
    #expect(array[safeIndex: 2] == 3)
    #expect(array[safeIndex: -1] == nil)
    #expect(array[safeIndex: 3] == nil)
}

// MARK: - OpID Tests

@Test func testOpIDComparison() {
    let id1 = OpID(counter: 1, id: user)
    let id2 = OpID(counter: 2, id: user)
    let id3 = OpID(counter: 2, id: otherUser)

    #expect(id1 < id2)
    #expect(id2 > id1)

    // Test same counter, different UUIDs
    #expect(id2 != id3)
    // Since user UUID < otherUser UUID
    #expect(id2 < id3)
}

@Test func testOpIDDescription() {
    let id = OpID(counter: 42, id: user)
    #expect(id.description == "42@\(user)")
}

// MARK: - Quilt Merge Tests

@Test func testMergeQuilt() {
    var quilt1 = Quilt(user: user)
    var quilt2 = Quilt(user: otherUser)

    quilt1.insert(character: "A", atIndex: 0)
    quilt2.insert(character: "B", atIndex: 0)

    quilt1.merge(quilt2)

    #expect(quilt1.operationLog.count == 2)
    #expect(quilt1.currentContent.count == 2)
}

@Test func testMergeDuplicateOperations() {
    var quilt1 = Quilt(user: user)
    var quilt2 = Quilt(user: otherUser)  // Changed to different user

    quilt1.insert(character: "A", atIndex: 0)
    quilt2.insert(character: "B", atIndex: 1)

    quilt1.merge(quilt2)

    // Should add both operationLog since they're from different users
    #expect(quilt1.operationLog.count == 2)
    #expect(quilt1.currentContent.count == 2)
}

// MARK: - Edge Cases Tests

@Test func testRemoveFromEmptyQuilt() {
    var quilt = Quilt(user: user)

    // Should not crash
    quilt.remove(atIndex: 0)
    #expect(quilt.operationLog.count == 0)
}

@Test func testRemoveFromInvalidIndex() {
    var quilt = Quilt(user: user)
    quilt.insert(character: "A", atIndex: 0)

    // Should not crash and should add the remove operation
    quilt.remove(atIndex: 1)
    #expect(quilt.operationLog.count == 2)
}

@Test func testInsertAtInvalidIndex() {
    var quilt = Quilt(user: user)

    // Should still work by inserting at the end
    quilt.insert(character: "A", atIndex: 999)
    #expect(quilt.operationLog.count == 1)
}

@Test func testPerf() {
    var quilt = Quilt(user: user)

    let str = """
    So fare thee well, poor devil of a Sub-Sub, whose commen- 
    tator I am. Thou belongest to that hopeless, sallow tribe 
    which no wine of this world will ever warm ; and for whom 
    even Pale Sherry would be too rosy-strong ; but with whom 
    one sometimes loves to sit, and feel poor-devilish, too ; and 
    grow convivial upon tears ; and say to them bluntly with full 
    eyes and empty glasses, and in not altogether unpleasant 
    sadness Give it up, Sub-Subs ! For by how much the more 
    pains ye take to please the world, by so much the more shall 
    ye forever go thankless ! Would that I could clear out 
    Hampton Court and the Tuileries for ye ! But gulp down 
    your tears and hie aloft to the royal-mast with your hearts ; 
    for your friends who have gone before are clearing out the 
    seven-storied heavens, and making refugees of long-pampered 
    Gabriel, Michael, and Raphael, against your coming. Here 
    ye strike but splintered hearts together there, ye shall 
    strike unsplinterable glasses! 
    """

    str.enumerated().forEach { (idx, char)in
        quilt.insert(character: char, atIndex: idx)
    }

    #expect(quilt.operationLog.count == 982)
}
