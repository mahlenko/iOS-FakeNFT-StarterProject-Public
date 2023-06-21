//
//  ProfileStore.swift
//  FakeNFT
//

import Foundation

final class ProfileStore {

    private let networkClient: NetworkClient
    private var networkTask: NetworkTask?

    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
    }
}

extension ProfileStore: ProfileStoreProtocol {

    func fetchProfile(completion: @escaping ((Result<ProfileModel, Error>) -> Void)) {
        networkTask?.cancel()
        let profileRequest = ProfileRequest()
        networkTask = networkClient.send(request: profileRequest, type: ProfileModel.self) { result in
            DispatchQueue.main.async { completion(result) }
        }
    }

    func updateProfile(_ profileModel: ProfileModel,
                       _ viewModelCompletion: @escaping (Result<ProfileModel, Error>) -> Void,
                       _ childViewModelCompletion: @escaping (() -> Void),
                       _ viewCompletion: @escaping (() -> Void)) {
        networkTask?.cancel()
        let updateProfileRequest = UpdateMainProfileRequest(profile: profileModel)
        networkTask = networkClient.send(request: updateProfileRequest, type: ProfileModel.self) { result in
            DispatchQueue.main.async {
                viewCompletion()
                childViewModelCompletion()
                viewModelCompletion(result)
            }
        }
    }
}
