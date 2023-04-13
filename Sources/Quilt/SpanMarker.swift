//
//  SpanMarker.swift
//
//
//  Created by Theodore Lampert on 15.12.22.
//

public enum SpanMarker: Codable, Equatable {
    case before(OpID)
    case after(OpID)
}
