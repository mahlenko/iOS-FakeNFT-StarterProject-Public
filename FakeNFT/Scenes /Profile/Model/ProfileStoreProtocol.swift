//
//  ProfileStoreProtocol.swift
//  FakeNFT
//

import Foundation

protocol ProfileStoreProtocol {
    func fetchProfile(completion: @escaping ((Result<ProfileModel, Error>) -> Void))
    func updateProfile(_ profileModel: ProfileModel,
                       _ viewModelCompletion: @escaping (Result<ProfileModel, Error>) -> Void,
                       _ childViewModelCompletion: @escaping (() -> Void),
                       _ viewCompletion: @escaping (() -> Void))
}
