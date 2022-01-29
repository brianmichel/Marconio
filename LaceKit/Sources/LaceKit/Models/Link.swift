//
//  Link.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation

public struct Link: Codable, Equatable {
    let href: String
    let rel: String
    let type: String
}
