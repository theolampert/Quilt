public extension Array {
    /// Safely access an array element at the given index, returning nil if the index is out of bounds
    /// - Parameter index: The index to access
    /// - Returns: The element at the index if it exists, nil otherwise
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
