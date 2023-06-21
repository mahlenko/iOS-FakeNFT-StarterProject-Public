//
//  UserIDStorageProtocol.swift
//  FakeNFT
//

import Foundation

protocol UserIDStorageProtocol {
    var userID: String? { get }
    func set(userID: String)
}
