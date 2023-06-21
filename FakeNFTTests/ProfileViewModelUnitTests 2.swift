//
//  ProfileUnitTests.swift
//  FakeNFTTests
//

import Foundation

import XCTest
@testable import FakeNFT

let fakeProfile = ProfileModel(name: "Joaquin Phoenix",
                               avatar: "https://wallpapers-fenix.eu/miniatura/160908/074553914.jpg",
                               description: "Observable",
                               website: "https://swiftblog.org",
                               nfts: [68, 69, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81],
                               likes: [1, 2, 3, 4, 5, 6, 7, 8, 9],
                               id: "1")

final class MockProfileStore: ProfileStoreProtocol {

    func fetchProfile(callback: @escaping ((Result<FakeNFT.ProfileModel, Error>) -> Void)) {
        callback(.success(fakeProfile))
    }

    func updateProfile(_ profileModel: FakeNFT.ProfileModel, _ viewModelCallback: @escaping (Result<FakeNFT.ProfileModel, Error>) -> Void, _ viewCallback: (() -> Void)?) {   }
}

final class ProfileViewModelUnitTests: XCTestCase {

    func testSetupViewModel() {
        // Given
        let mockProfileStore = MockProfileStore()
        let profileViewModel = ProfileViewModel(profileStore: mockProfileStore, userIDStorage: UserIDStorage())

        // When
        profileViewModel.needUpdate()

        // Then
        XCTAssertEqual(fakeProfile.name, profileViewModel.name)
        XCTAssertEqual(fakeProfile.avatar, profileViewModel.avatarURL?.description)
        XCTAssertEqual(fakeProfile.description, profileViewModel.description)
        XCTAssertEqual(fakeProfile.website, profileViewModel.website)
        XCTAssertEqual(fakeProfile.nfts, profileViewModel.nfts)
        XCTAssertEqual(fakeProfile.likes, profileViewModel.likes)
    }
}
