//
//  QuiltTests.swift
//
//
//  Created by Theodore Lampert on 29.01.23.
//

@testable import Quilt
import XCTest

final class QuiltTests: XCTestCase {
    // MARK: - Test Setup
    let user = UUID(uuidString: "E2DFDB75-A3D9-4B55-9312-111EF297D566")!
    let otherUser = UUID(uuidString: "F3DFDB75-A3D9-4B55-9312-111EF297D567")!

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
    
    // MARK: - Array Extension Tests
    
    func testArraySafeIndex() {
        let array = [1, 2, 3]
        
        XCTAssertEqual(array[safeIndex: 0], 1)
        XCTAssertEqual(array[safeIndex: 2], 3)
        XCTAssertNil(array[safeIndex: -1])
        XCTAssertNil(array[safeIndex: 3])
    }
    
    // MARK: - OpID Tests
    
    func testOpIDComparison() {
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
    
    func testOpIDDescription() {
        let id = OpID(counter: 42, id: user)
        XCTAssertEqual(id.description, "42@\(user)")
    }
    
    // MARK: - Quilt Merge Tests
    
    func testMergeQuilt() {
        var quilt1 = Quilt(user: user)
        var quilt2 = Quilt(user: otherUser)
        
        quilt1.insert(character: "A", atIndex: 0)
        quilt2.insert(character: "B", atIndex: 0)
        
        quilt1.merge(quilt2)
        
        XCTAssertEqual(quilt1.operations.count, 2)
        XCTAssertEqual(quilt1.appliedOps.count, 2)
    }
    
    func testMergeDuplicateOperations() {
        var quilt1 = Quilt(user: user)
        var quilt2 = Quilt(user: otherUser)  // Changed to different user
        
        quilt1.insert(character: "A", atIndex: 0)
        quilt2.operations = quilt1.operations
        quilt2.insert(character: "B", atIndex: 1)
        
        quilt1.merge(quilt2)
        
        // Should add both operations since they're from different users
        XCTAssertEqual(quilt1.operations.count, 2)
        XCTAssertEqual(quilt1.appliedOps.count, 2)
    }
    
    // MARK: - Edge Cases Tests
    
    func testRemoveFromEmptyQuilt() {
        var quilt = Quilt(user: user)
        
        // Should not crash
        quilt.remove(atIndex: 0)
        XCTAssertEqual(quilt.operations.count, 0)
    }
    
    func testRemoveFromInvalidIndex() {
        var quilt = Quilt(user: user)
        quilt.insert(character: "A", atIndex: 0)
        
        // Should not crash and should add the remove operation
        quilt.remove(atIndex: 1)
        XCTAssertEqual(quilt.operations.count, 2)
    }
    
    func testInsertAtInvalidIndex() {
        var quilt = Quilt(user: user)
        
        // Should still work by inserting at the end
        quilt.insert(character: "A", atIndex: 999)
        XCTAssertEqual(quilt.operations.count, 1)
    }
}
