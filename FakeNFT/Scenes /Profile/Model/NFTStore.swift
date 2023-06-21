//
//  NFTStore.swift
//  FakeNFT
//

import Foundation

final class NFTStore {

    private let networkClient: NetworkClient
    private let dispatchGroup: DispatchGroup
    private var networkTasks: [NetworkTask]
    private var nftResults: [Result<Nft, Error>]

    init(networkClient: NetworkClient = DefaultNetworkClient()) {
        self.networkClient = networkClient
        self.dispatchGroup = DispatchGroup()
        self.networkTasks = []
        self.nftResults = []
    }

    private func cancelExistingNetworkTasks() {
        guard !networkTasks.isEmpty else { return }
        networkTasks.forEach { $0.cancel() }
    }
}

// MARK: - NFTStoreProtocol

extension NFTStore: NFTStoreProtocol {

    func getNFTs(using nftIDs: [Int], completion: @escaping (([Result<Nft, Error>]) -> Void)) {
        cancelExistingNetworkTasks()
        nftIDs.forEach { nftID in
            dispatchGroup.enter()
            let nftRequest = NftRequest(id: nftID)
            //let nftPathComponentString = String(format: Constants.nftPathComponentString, nftID)
            //let nftRequest = NFTRequest(endpoint: URL(string: Constants.endpointURLString + nftPathComponentString))
            let networkTask = networkClient.send(request: nftRequest, type: Nft.self) { [weak self] result in
                DispatchQueue.main.async {
                    self?.nftResults.append(result)
                    self?.dispatchGroup.leave()
                }
            }
            if let task = networkTask { networkTasks.append(task) }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self = self else { return }
            completion(self.nftResults)
            self.nftResults = []
        }
    }
}
