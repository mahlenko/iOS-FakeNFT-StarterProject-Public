//
//  UserIDStorage.swift
//  FakeNFT
//

import Foundation

final class UserIDStorage: UserIDStorageProtocol {

    private enum Keys: String {
        case userID
    }

    private let userDefaults: UserDefaults

    private(set) var userID: String? {
        get {
            guard let userID = userDefaults.string(forKey: Keys.userID.rawValue) else {
                print("Unable to get userID value from local storage")
                return nil
            }
            return userID
        }
        set {
            userDefaults.set(newValue, forKey: Keys.userID.rawValue)
        }
    }

    init() {
        self.userDefaults = UserDefaults.standard
        self.set(userID: Constants.fakeUserIDString)
    }

    func set(userID: String) {
        self.userID = userID
    }
}
