import Foundation

//MARK: вынести протоколы в отдельные файлы по завешению
protocol CollectionViewModelProtocol {
    var onNFTCollectionInfoUpdate: (() -> Void)? { get set }
    var onNFTAuthorUpdate: (() -> Void)? { get set }
    func getNFTCollectionInfo(id: Int)
    func getNFTCollectionAuthor(id: Int)
    var NFTCollection: NFTCollection? { get }
    var NFTCollectionAuthor: NFTCollectionAuthor? { get }
    var NFTItemsCount: Int? { get }
}

final class CollectionViewModel: CollectionViewModelProtocol {
    var onNFTCollectionInfoUpdate: (() -> Void)?
    var onNFTAuthorUpdate: (() -> Void)?
    var model: CollectionModelProtocol
    var NFTCollection: NFTCollection?
    var NFTCollectionAuthor: NFTCollectionAuthor?
    var NFTItemsCount: Int?
    
    init(model: CollectionModelProtocol) {
        self.model = model
    }
    
    func getNFTCollectionInfo(id: Int) {
        model.getNFTCollectionInfo(id: id) { [weak self] result in
            switch result {
            case .success(let data):
                self?.NFTCollection = data
                self?.NFTItemsCount = data.nfts.count
                self?.onNFTCollectionInfoUpdate?()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getNFTCollectionAuthor(id: Int) {
        model.getNFTCollectionAuthor(id: id) { [weak self] result in
            switch result {
            case .success(let data):
                self?.NFTCollectionAuthor = data
                self?.onNFTAuthorUpdate?()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
