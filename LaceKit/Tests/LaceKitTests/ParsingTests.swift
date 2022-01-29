//
//  ParsingTests.swift
//  
//
//  Created by Brian Michel on 1/27/22.
//

import XCTest
@testable import LaceKit

class ParsingTests: XCTestCase {

    func testParsesLiveBroadcastsCorrectly() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let data = twoChannelLiveBroadcastData()

            let response = try decoder.decode(LiveBroadcastsResponse.self, from: data)
            XCTAssertTrue(response.results.count == 2)
        } catch {
            XCTFail("Unable to decode live broadcasts from known working JSON. \(error)")
        }
    }

    func testParsesMixtapesCorrectly() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            let data = infiniteMixtapesData()

            let response = try decoder.decode(MixtapesResponse.self, from: data)
            XCTAssertTrue(response.results.count == 14)
        } catch {
            XCTFail("Unable to decode mixtapes from known working JSON. \(error)")
        }
    }

    private func twoChannelLiveBroadcastData() -> Data {
        let url = Bundle.module.url(forResource: "live-broadcasts-working", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        return data
    }

    private func infiniteMixtapesData() -> Data {
        let url = Bundle.module.url(forResource: "mixtapes-working", withExtension: "json")
        let data = try! Data(contentsOf: url!)
        return data
    }

}
