# Quilt

An (incomplete) Swift implementation of operation-based CRDTs for rich text editing, inspired by Ink & Switch's [Peritext](https://www.inkandswitch.com/peritext/) essay. Intended to be used by a higher level API.

## Features

- Support for basic text operations (insert/delete)
- Rich text formatting (bold, italic, underline)
- Automatic merging of concurrent edits
- Preserves intent of formatting across concurrent edits

## Usage

### Basic Text Operations

```swift
// Initialize with a unique user ID
let doc = Quilt(user: UUID())

// Insert characters
doc.insert(character: "H", atIndex: 0)
doc.insert(character: "i", atIndex: 1)

// Remove characters
doc.remove(atIndex: 1) // Removes "i"
```

### Text Formatting

```swift
// Add some text
doc.insert(character: "H", atIndex: 0)
doc.insert(character: "e", atIndex: 1)
doc.insert(character: "l", atIndex: 2)
doc.insert(character: "l", atIndex: 3)
doc.insert(character: "o", atIndex: 4)

// Apply bold formatting to the entire word
doc.addMark(mark: .bold, fromIndex: 0, toIndex: 4)

// Remove bold formatting
doc.removeMark(mark: .bold, fromIndex: 0, toIndex: 4)
```

### Collaborative Editing

```swift
var doc1 = Quilt(user: UUID())
var doc2 = Quilt(user: UUID())

// Make changes in both instances
doc1.insert(character: "A", atIndex: 0)
doc2.insert(character: "B", atIndex: 0)

// Merge changes
doc1.merge(doc2)
doc2.merge(doc1)

// Both instances now have the same content
```

This ensures that concurrent operations can be merged deterministically across all instances of the document.

## Available Operations

- `insert(character:atIndex:)`: Insert a character at a specific position
- `remove(atIndex:)`: Remove a character at a specific position
- `addMark(mark:fromIndex:toIndex:)`: Apply formatting to a range of text
- `removeMark(mark:fromIndex:toIndex:)`: Remove formatting from a range of text
- `merge(_:)`: Merge changes from another Quilt instance

## Formatting Options

The following formatting marks are available:
- `.bold`
- `.italic`
- `.underline`
