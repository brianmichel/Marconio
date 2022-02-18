//
//  Either.swift
//  
//
//  Created by Brian Michel on 2/13/22.
//

import Foundation

public enum Either<Left: Equatable, Right: Equatable>: Equatable {
    case left(Left)
    case right(Right)
}
