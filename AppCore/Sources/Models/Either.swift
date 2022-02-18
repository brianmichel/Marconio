//
//  Either.swift
//  
//
//  Created by Brian Michel on 2/13/22.
//

import Foundation

/**
 An enumeration that lets you conditionally bind against a value that is either
 a type of `Left` or a type of `Right`. Good for holding underlying type infromation
 in an otherwise erased typed.

 Example usage below for conditional binding in a switch.

 ```
 public var source: Either<Channel, Mixtape>

 ...

 switch source {
    case let .left(channel):
    ...
    case let .right(mixtape):
    ...
 ```

 Or you could use this in an if statement to bind the left or right to gate some logic.

 ```
 public var source: Either<Channel, Mixtape>
 ...

 if case let .left(channel) = source {
    ...
 }
 ```
 */
public enum Either<Left: Equatable, Right: Equatable>: Equatable {
    case left(Left)
    case right(Right)
}
