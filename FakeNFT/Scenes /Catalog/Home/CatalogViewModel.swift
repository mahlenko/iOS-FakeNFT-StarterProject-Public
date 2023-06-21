import Foundation

final class CatalogViewModel: CatalogViewModelProtocol {
    var onNFTCollectionsUpdate: (() -> Void)?
    var showAlertClosure: (() -> Void)?
    var errorMessage: String? {
        didSet {
            showAlertClosure?()
        }
    }
    var updateLoadingStatus: (() -> Void)?
    var isLoading: Bool {
        didSet {
            updateLoadingStatus?()
        }
    }
    var NFTCollections: [NFTCollection]?
    var NFTCollectionsList: [NFTCollectionListItem]?
    var NFTCollectionsCount: Int?
    var networkClient: NetworkClient
    let storeService = StoreService()
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
        isLoading = false
    }
    
    func getNFTCollections() {
        isLoading = true
        
        networkClient.send(request: NFTCollectionsRequest(), type: [NFTCollection].self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.isLoading = false
                self.NFTCollections = data
                self.NFTCollectionsCount = data.count
                self.NFTCollectionsList = self.convert(collection: data)
                if let sortAttribute = self.storeService.getValue(for: .nftCollectionsSortAttribute, type: .string) as? String {
                    if sortAttribute == "name" {
                        self.sortNFTCollections(by: .name)
                    } else if sortAttribute == "nftCount" {
                        self.sortNFTCollections(by: .nftCount)
                    }
                }
                self.onNFTCollectionsUpdate?()
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func sortNFTCollections(by: NFTCollectionsSortAttributes) {
        switch by {
        case .name:
            NFTCollectionsList?.sort { $0.name < $1.name }
        case .nftCount:
            NFTCollectionsList?.sort { $0.nftsCount < $1.nftsCount }
        }
        storeService.store(key: .nftCollectionsSortAttribute, value: by.rawValue)
        onNFTCollectionsUpdate?()
    }
    
    private func convert(collection: [NFTCollection]) -> [NFTCollectionListItem] {
        var list: [NFTCollectionListItem] = []
        collection.forEach {
            guard let id = Int($0.id) else { return }
            list.append(
                NFTCollectionListItem(
                    id: id,
                    name: $0.name,
                    cover: $0.cover,
                    nftsCount: $0.nfts.count
                )
            )
        }
        return list
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> NFTCollectionListItem? {
        guard let list = NFTCollectionsList,
            indexPath.row < list.count
        else { return nil }
        return list[indexPath.row]
    }
}
