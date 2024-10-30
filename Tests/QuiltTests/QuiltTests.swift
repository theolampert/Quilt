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

func getString(_ doc: Quilt) -> String {
    doc.currentContent.reduce(into: "") { acc, curr in
        if case let .insert(character) = curr.type {
            acc.append(character)
        }
    }
}

@Test func testAddRemoveOps() throws {
    var quilt = Quilt(user: user)

    quilt.insert(character: "T", atIndex: 0)

    #expect(
        quilt.operationLog[0] == Operation(
            opId: OpID(counter: 0, userID: user),
            type: .insert("T"),
            afterId: nil
        )
    )

    quilt.insert(character: "H", atIndex: 1)

    #expect(
        quilt.operationLog[1] == Operation(
            opId: OpID(counter: 1, userID: user),
            type: .insert("H"),
            afterId: quilt.operationLog[0].id
        )
    )

    quilt.remove(atIndex: 1)

    #expect(
        quilt.operationLog[2] == Operation(
            opId: OpID(counter: 2, userID: user),
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
        opId: OpID(counter: 5, userID: user),
        type: .addMark(
            type: .bold,
            start: .before(OpID(counter: 0, userID: user)),
            end: .before(OpID(counter: 4, userID: user))
        )
    ))

    quilt.removeMark(
        mark: .bold,
        fromIndex: 0,
        toIndex: 4
    )

    #expect(quilt.operationLog[6] == Operation(
        opId: OpID(counter: 6, userID: user),
        type: .removeMark(
            type: .bold,
            start: .before(OpID(counter: 0, userID: user)),
            end: .before(OpID(counter: 4, userID: user))
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
    let id1 = OpID(counter: 1, userID: user)
    let id2 = OpID(counter: 2, userID: user)
    let id3 = OpID(counter: 2, userID: otherUser)

    #expect(id1 < id2)
    #expect(id2 > id1)

    // Test same counter, different UUIDs
    #expect(id2 != id3)
    // Since user UUID < otherUser UUID
    #expect(id2 < id3)
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

@Test func testConcurrentEdits() {
    var doc1 = Quilt(user: user)
    var doc2 = Quilt(user: otherUser)

    let str = "The quick brown fox"
    str.enumerated().forEach { (idx, char) in
        doc1.insert(character: char, atIndex: idx)
    }

    doc2.merge(doc1)

    doc2.remove(atIndex: 18)
    doc2.remove(atIndex: 17)
    doc2.remove(atIndex: 16)

    doc2.insert(character: "c", atIndex: 16)
    doc2.insert(character: "a", atIndex: 17)
    doc2.insert(character: "t", atIndex: 18)

    doc1.remove(atIndex: 18)
    doc1.remove(atIndex: 17)
    doc1.remove(atIndex: 16)

    doc1.insert(character: "d", atIndex: 16)
    doc1.insert(character: "o", atIndex: 17)
    doc1.insert(character: "g", atIndex: 18)

    #expect(getString(doc1) == "The quick brown dog")
    #expect(getString(doc2) == "The quick brown cat")

    doc1.merge(doc2)
    doc2.merge(doc1)

    #expect(getString(doc1) == "The quick brown catdog")
    #expect(getString(doc2) == "The quick brown catdog")
}

@Test func testConcurrentEditsOfSameWord() {
    var doc1 = Quilt(user: user)
    var doc2 = Quilt(user: otherUser)

    let str = "The quick brown fox"
    str.enumerated().forEach { (idx, char) in
        doc1.insert(character: char, atIndex: idx)
    }

    doc2.merge(doc1)

    doc2.remove(atIndex: 18)
    doc2.remove(atIndex: 17)
    doc2.remove(atIndex: 16)

    doc2.insert(character: "c", atIndex: 16)
    doc2.insert(character: "a", atIndex: 17)
    doc2.insert(character: "t", atIndex: 18)

    doc1.remove(atIndex: 18)
    doc1.remove(atIndex: 17)
    doc1.remove(atIndex: 16)

    doc1.insert(character: "c", atIndex: 16)
    doc1.insert(character: "a", atIndex: 17)
    doc1.insert(character: "t", atIndex: 18)

    #expect(getString(doc1) == "The quick brown cat")
    #expect(getString(doc2) == "The quick brown cat")

    doc1.merge(doc2)
    doc2.merge(doc1)

    #expect(getString(doc1) == "The quick brown cat")
    #expect(getString(doc2) == "The quick brown cat")
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
    xiv MOBY-DICK 

    ' He visited this country also with a view of catching horse - 
    whales, which had bones of very great value for their teeth, 
    of which he brought some to the king. * * * The best 
    whales were catched in his own country, of which some were 
    forty-eight, some fifty yards long. He said that he was one 
    of six who had killed sixty in two days.' 

    Other or Octher's verbal narrative taken down 
    from his mouth by King Alfred, A.D. 890. 

    1 And whereas all the other things, whether beast or vessel, 
    that enter into the dreadful gulf of this monster's (whale's) 
    mouth, are immediately lost and swallowed up, the sea- 
    gudgeon retires into it in great security, and there sleeps.' 
    Montaigne 1 s Apology for Eaimond Sebond. 

    ' Let us fly, let us fly ! Old Nick take me if it is not 
    Leviathan described by the noble prophet Moses in the life 
    of patient Job.' Rabelais. 

    ' This whale's liver was two cart-loads.' 

    Stowe's Annals. 

    1 The great Leviathan that maketh the seas to seethe like 
    boiling pan.' Lord Bacon's Version of the Psalms. 

    ' Touching that monstrous bulk of the whale or ork we 
    have received nothing certain. They grow exceeding fat, 
    insomuch that an incredible quantity of oil will be extracted 
    out of one whale.' Ibid. History of Life and Death. 

    1 The sovereignest thing on earth is parmacetti for an in- 
    ward bruise.' King Henry. 

    ' Very like a whale.' Hamlet. 

    ' Which to secure, no skill of leach's art 
    Mote him availle, but to returne againe 
    To his wound's worker, that with lowly dart, 
    Dinting his breast, had bred his restless paine, 
    Like as the wounded whale to shore flies thro' the maine.' 

    The Fairie Queen. 

    ' Immense as whales, the motion of whose vast bodies can 
    in a peaceful calm trouble the ocean till it boil.' 

    Sir William Davenant's Preface to Gondibert. 



    EXTRACTS xv 

    ' What spermaceti! is, men might justly doubt, since the 
    learned Hosmannus in his work of thirty years, saith plainly, 
    Nescio quid sit.' 

    Sir T. Browne's Of Sperma Ceti and the 
    Sperma Ceti Whale. Vide his V.E. 

    ' Like Spencer's Talus with his modern flail 

    He threatens ruin with his p
    """

    str.enumerated().forEach { (idx, char)in
        quilt.insert(character: char, atIndex: idx)
    }

    #expect(quilt.operationLog.count == 2136)
}
