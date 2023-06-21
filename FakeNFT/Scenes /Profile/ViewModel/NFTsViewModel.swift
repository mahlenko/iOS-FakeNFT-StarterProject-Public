//
//  NFTViewModel.swift
//  FakeNFT
//

import Foundation

enum SortingMethod {
    case price, rating, name
}

final class NFTsViewModel {

    private let nftStore: NFTStoreProtocol
    private weak var profileViewModel: ProfileViewModelProtocol?

    private var nftIDs: [Int]

    @Observable
    private(set) var nftViewModels: [NFTViewModel]
    @Observable
    private var isNFTsDownloadingNow: Bool
    @Observable
    private var nftsReceivingError: String

    init(for nftIDs: [Int],
         profileViewModel: ProfileViewModelProtocol,
         nftStore: NFTStoreProtocol = NFTStore()) {
        self.nftIDs = nftIDs
        self.profileViewModel = profileViewModel
        self.nftStore = nftStore
        self.nftViewModels = []
        self.isNFTsDownloadingNow = false
        self.nftsReceivingError = ""
    }

    private func setNFTsViewModel(from nftModels: [Nft]) {
        nftViewModels = nftModels.map {
            NFTViewModel(name: $0.name,
                         image: URL(string: $0.images.first ?? ""),
                         rating: $0.rating,
                         author: Constants.mockAuthorString,
                         price: String($0.price).replacingOccurrences(of: ".", with: ",") + Constants.mockCurrencyString,
                         id: $0.id)
        }.sorted { $0.id < $1.id }
    }

    private func handle(_ error: Error) {
        nftsReceivingError = String(format: L10n.nftsReceivingError, error as CVarArg)
    }
}

// MARK: - NFTsViewModelProtocol

extension NFTsViewModel: NFTsViewModelProtocol {

    var myNFTsTitle: String { L10n.myNFTsTitle }

    var favoritesNFTsTitle: String { L10n.favoritesNFTsTitle }

    var nftViewModelsObservable: Observable<[NFTViewModel]> { $nftViewModels }

    var isNFTsDownloadingNowObservable: Observable<Bool> { $isNFTsDownloadingNow }

    var nftsReceivingErrorObservable: Observable<String> { $nftsReceivingError }

    var stubLabelIsHidden: Bool { !nftIDs.isEmpty }

    func needUpdate() {
        if nftIDs.isEmpty {
            nftViewModels = []
            return
        }
        isNFTsDownloadingNow = true
        nftStore.getNFTs(using: nftIDs) { [weak self] results in
            var nftModels: [Nft] = []
            results.forEach { result in
                switch result {
                case .success(let nftModel): nftModels.append(nftModel)
                case .failure(let error): self?.handle(error)
                }
            }
            self?.setNFTsViewModel(from: nftModels)
            self?.isNFTsDownloadingNow = false
        }
    }

    func nftsUpdated(newNFTs: [Int]) {
        nftIDs = newNFTs
        needUpdate()
    }

    func myNFTSorted(by sortingMethod: SortingMethod) {
        switch sortingMethod {
        case .price: nftViewModels.sort { Float($0.price.dropLast(4).replacingOccurrences(of: ",", with: ".")) ?? 0
            < Float($1.price.dropLast(4).replacingOccurrences(of: ",", with: ".")) ?? 0 }
        case .rating: nftViewModels.sort { $0.rating > $1.rating }
        case .name: nftViewModels.sort { $0.name < $1.name }
        }
    }

    func didTapLike(nft: Int, completion: @escaping () -> Void) {
        isNFTsDownloadingNow = true
        var updatedNFTViewModels = nftViewModels
        updatedNFTViewModels.remove(at: nft)
        var updatedLikes: [Int] = []
        updatedNFTViewModels.forEach { updatedLikes.append(Int($0.id) ?? 0) }
        profileViewModel?.didChangeProfile(name: nil,
                                           description: nil,
                                           website: nil,
                                           likes: updatedLikes,
                                           viewCompletion: completion) { [weak self] in
            self?.isNFTsDownloadingNow = false
        }
    }
}
