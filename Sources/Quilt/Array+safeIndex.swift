//
//  Array+safeIndex.swift
//  
//
//  Created by Theodore Lampert on 08.12.22.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
