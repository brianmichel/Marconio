//
//  LinkTests.swift
//  
//
//  Created by Brian Michel on 2/9/22.
//

@testable import Models
import XCTest

class LinkTests: XCTestCase {
    func testLinkRemovesAPIComponents() {
        let link = Link(href: "https://www.nts.live/api/v2/shows/word-of-command/episodes/word-of-command-9th-february-2022", rel: "self", type: "application/vnd.episode+json;charset=utf-8")

        let endURL = URL(string: "https://www.nts.live/shows/word-of-command/episodes/word-of-command-9th-february-2022")!

        XCTAssertEqual(endURL, link.hrefWithAPIRemoved)
    }

    func testLinkNotRemovedForShortHrefs() {
        let link = Link(href: "https://www.nts.live/shows/", rel: "self", type: "application/vnd.episode+json;charset=utf-8")


        XCTAssertNil(link.hrefWithAPIRemoved)
    }

    func testLinkNoChancesIfApiOrV2NotPresent() {
        let link = Link(href: "https://www.nts.live/shows/something-cool-goes-here/episodes/another-cool-think", rel: "self", type: "application/vnd.episode+json;charset=utf-8")

        let endURL = URL(string: "https://www.nts.live/shows/something-cool-goes-here/episodes/another-cool-think")!

        XCTAssertEqual(link.hrefWithAPIRemoved, endURL)
    }
}
