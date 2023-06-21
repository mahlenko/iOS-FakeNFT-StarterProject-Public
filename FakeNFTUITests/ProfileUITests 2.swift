//
//  ProfileUITests.swift
//  FakeNFTUITests
//

import XCTest

final class ProfileUITests: XCTestCase {

    private enum ProfileUITestsError: Error {
        case favoritesNFTsIsEmpty
    }

    func testLikeButton() throws {
        let app = XCUIApplication()
        app.launch()

        let table = app.tables.matching(identifier: "profileTable")
        let tableCell = table.cells.element(matching: .cell, identifier: "cell-1")
        tableCell.tap()

        sleep(3)

        let collection = app.collectionViews.matching(identifier: "favoritesNFTCollection")
        guard collection.cells.count != 0 else { throw ProfileUITestsError.favoritesNFTsIsEmpty }
        let collectionCell = collection.cells.element(matching: .cell, identifier: "cell-1")
        let likeButton = collectionCell.buttons.element(matching: .button, identifier: "like")
        let nftsCountBeforeTapLike = collection.cells.count
        likeButton.tap()

        sleep(3)

        let nftsCountAfterTapLike = app.collectionViews.cells.count
        XCTAssertEqual(nftsCountBeforeTapLike, nftsCountAfterTapLike + 1)
    }
}
