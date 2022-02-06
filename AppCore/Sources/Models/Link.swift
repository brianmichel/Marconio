//
//  Link.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import Foundation

/**
 A representation of an additional 'link' from the API's perspective.

 A link can mean many things within the NTS API, but it seems to more or
 less represent another _endpoint_ that could be hit, or the one that was just hit.
 This seems in the vein of something like a hypermedia API which can be self-referential
 and self-linking so you could 'browse' the API so to speak.
 */
public struct Link: Codable, Equatable {
    /// The URL (as a `String`) that is represents the resouce.
    let href: String
    /// The relationship that the `href` has to the response object.
    /// This is always a string representing the relationship.
    let rel: String
    /// The content type of the resource in question.
    let type: String
}
