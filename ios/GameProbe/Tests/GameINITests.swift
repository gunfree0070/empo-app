import XCTest

@testable import GameProbe

final class GameINITests: XCTestCase {

    private func writeINI(_ contents: String) throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let iniURL = dir.appendingPathComponent("Game.ini")
        try contents.write(to: iniURL, atomically: true, encoding: .utf8)
        return iniURL
    }

    func testParsesTitleWithSpaceBeforeEquals() throws {
        let iniURL = try writeINI(
            """
            [Game]
            title =BLACK SOULS
            """)
        XCTAssertEqual(
            GameINI.parseINIValue(in: iniURL, section: "game", key: "title"),
            "BLACK SOULS")
    }

    func testParsesTitleWithoutSpacesAroundEquals() throws {
        let iniURL = try writeINI(
            """
            [Game]
            Title=Pokemon Reborn
            """)
        XCTAssertEqual(
            GameINI.parseINIValue(in: iniURL, section: "game", key: "title"),
            "Pokemon Reborn")
    }

    func testParsesRTPWithSpaceBeforeEquals() throws {
        let iniURL = try writeINI(
            """
            [Game]
            rtp =RPGVXAce
            """)
        XCTAssertEqual(
            GameINI.parseINIValue(in: iniURL, section: "game", key: "rtp"),
            "RPGVXAce")
    }

    func testParsesScriptsPathWithBackslashes() throws {
        let iniURL = try writeINI(
            """
            [Game]
            scripts =Data\\Scripts.rvdata2
            """)
        XCTAssertEqual(
            GameINI.parseINIValue(in: iniURL, section: "game", key: "scripts"),
            "Data\\Scripts.rvdata2")
    }

    func testIgnoresOtherSections() throws {
        let iniURL = try writeINI(
            """
            [Options]
            title=Wrong Section
            [Game]
            title=Right Section
            """)
        XCTAssertEqual(
            GameINI.parseINIValue(in: iniURL, section: "game", key: "title"),
            "Right Section")
    }
}
