import Foundation

protocol CatalogViewModelProtocol {
    var onNFTCollectionsUpdate: (() -> Void)? { get set }
    var showAlertClosure: (() -> Void)? { get set }
    var errorMessage: String? { get }
    var updateLoadingStatus: (() -> Void)? { get set }
    var isLoading: Bool { get set }
    var NFTCollections: [NFTCollection]? { get }
    var NFTCollectionsList: [NFTCollectionListItem]? { get }
    var networkClient: NetworkClient { get }
    var NFTCollectionsCount: Int? { get }
    func getNFTCollections()
    func getCellViewModel(at indexPath: IndexPath) -> NFTCollectionListItem?
    func sortNFTCollections(by: NFTCollectionsSortAttributes)
}
