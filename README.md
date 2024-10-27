# Quilt

An (incomplete) Swift implementation of operation-based CRDTs for rich text editing, inspired by Ink & Switch's [Peritext](https://www.inkandswitch.com/peritext/) essay. Intended to be used by a higher level API see [QuiltString](https://github.com/theolampert/QuiltString).

## Features

- Conflict-free collaborative text editing
- Support for basic text operations (insert/delete)
- Rich text formatting (bold, italic, underline)
- Automatic merging of concurrent edits
- Preserves intent of formatting across concurrent edits

## Usage

### Basic Text Operations

```swift
// Initialize with a unique user ID
let quilt = Quilt(user: UUID())

// Insert characters
quilt.insert(character: "H", atIndex: 0)
quilt.insert(character: "i", atIndex: 1)

// Remove characters
quilt.remove(atIndex: 1) // Removes "i"
```

### Text Formatting

```swift
// Add some text
quilt.insert(character: "H", atIndex: 0)
quilt.insert(character: "e", atIndex: 1)
quilt.insert(character: "l", atIndex: 2)
quilt.insert(character: "l", atIndex: 3)
quilt.insert(character: "o", atIndex: 4)

// Apply bold formatting to the entire word
quilt.addMark(mark: .bold, fromIndex: 0, toIndex: 4)

// Remove bold formatting
quilt.removeMark(mark: .bold, fromIndex: 0, toIndex: 4)
```

### Collaborative Editing

```swift
var quilt1 = Quilt(user: UUID())
var quilt2 = Quilt(user: UUID())

// Make changes in both instances
quilt1.insert(character: "A", atIndex: 0)
quilt2.insert(character: "B", atIndex: 0)

// Merge changes
quilt1.merge(quilt2)
quilt2.merge(quilt1)

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
