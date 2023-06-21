import Foundation

final class CollectionViewModel: CollectionViewModelProtocol {
    var onNFTCollectionInfoUpdate: (() -> Void)?
    var onNFTAuthorUpdate: (() -> Void)?
    var onNFTItemsUpdate: (() -> Void)?
    var showAlertClosure: (() -> Void)?
    var onNFTChanged: (() -> Void)?
    
    var errorMessage: String? {
        didSet {
            showAlertClosure?()
            isLoading = false
        }
    }
    var updateLoadingStatus: (() -> Void)?
    var isLoading: Bool {
        didSet {
            updateLoadingStatus?()
        }
    }
    private(set) var allNFTItems: [Nft]? {
        didSet {
            generateNFTdata()
        }
    }
    private(set) var nftsLiked: NFTLiked? {
        didSet {
            generateNFTdata()
        }
    }
    private(set) var nftsInCart: NFTsInCart? {
        didSet {
            generateNFTdata()
        }
    }
    
    var networkClient: NetworkClient
    var nftCollectionId: Int
    var converter: CryptoConverterProtocol
    private(set) var nftCollection: NFTCollection?
    private(set) var nftCollectionAuthor: User?
    private(set) var nftCollectionItems: [NFTCollectionNFTItem]?
    private(set) var nftCollectionItemsCount: Int?
    
    init(networkClient: NetworkClient, nftCollectionId: Int, converter: CryptoConverterProtocol) {
        self.networkClient = networkClient
        self.nftCollectionId = nftCollectionId
        self.converter = converter
        isLoading = false
    }
    
    func getNFTCollectionInfo() {
        isLoading = true
        networkClient.send(request: NFTCollectionRequest(id: nftCollectionId), type: NFTCollection.self)  { [weak self] result in
            switch result {
            case .success(let data):
                self?.nftCollection = data
                self?.onNFTCollectionInfoUpdate?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }

    func getNFTCollectionAuthor(id: Int) {
        networkClient.send(request: UserRequest(id: id), type: User.self)  { [weak self] result in
            switch result {
            case .success(let data):
                self?.nftCollectionAuthor = data
                self?.onNFTAuthorUpdate?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func getNFTCollectionItems() {
        allNFTItems = nil
        nftsLiked = nil
        nftsInCart = nil
        
        getAllNFTs { [weak self] result in
            switch result {
            case .success(let data):
                self?.allNFTItems = data
            case .failure(let error):
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
            }
        }
        
        getLikedNFTs { [weak self] result in
            switch result {
            case .success(let data):
                self?.nftsLiked = data
            case .failure(let error):
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
            }
        }
        
        getNFTsInCart { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let data):
                self?.nftsInCart = data
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func getAllNFTs(completion: @escaping (Result<[Nft], Error>) -> Void) {
        networkClient.send(request: AllNFTsRequest(), type: [Nft].self)  { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getLikedNFTs(completion: @escaping (Result<NFTLiked, Error>) -> Void) {
        networkClient.send(request: ProfileRequest(), type: NFTLiked.self)  { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getNFTsInCart(completion: @escaping (Result<NFTsInCart, Error>) -> Void) {
        networkClient.send(request: OrderRequest(id: Strings.orderNumber), type: NFTsInCart.self)  { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func toggleArrayItem<E: Equatable>(array: [E], item: E) -> [E] {
        var newArray = array
        if let index = array.firstIndex(where: { $0 == item }) {
            newArray.remove(at: index)
        } else {
            newArray.append(item)
        }
        return newArray
    }
    
    func toggleCart(id: Int) {
        isLoading = true
        networkClient.send(request: OrderRequest(id: Strings.orderNumber), type: NFTsInCart.self)  { [weak self] result in
            switch result {
            case .success(let data):
                let newOrder = Order(nfts: self?.toggleArrayItem(array: data.nfts, item: id) ?? [], id: Strings.orderNumber)
                self?.networkClient.send(request: UpdateOrderRequest(order: newOrder), type: Order.self) { result in
                    switch result {
                    case .success(let data):
                        self?.nftsInCart = NFTsInCart(nfts: data.nfts)
                        self?.onNFTItemsUpdate?()
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    func toggleLike(id: Int) {
        isLoading = true
        networkClient.send(request: ProfileRequest(), type: NFTLiked.self)  { [weak self] result in
            switch result {
            case .success(let data):
                let newLikesInProfile = NFTLiked(likes: self?.toggleArrayItem(array: data.likes, item: id) ?? [])
                self?.networkClient.send(request: UpdateProfileLikesRequest(id: 1, likes: newLikesInProfile), type: NFTLiked.self) { result in
                    switch result {
                    case .success(let data):
                        self?.nftsLiked = NFTLiked(likes: data.likes)
                        self?.onNFTItemsUpdate?()
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
                
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func generateNFTdata() {
        guard let allNFTItems = allNFTItems,
              let nftsLiked = nftsLiked,
              let nftsInCart = nftsInCart,
              let nfts = nftCollection?.nfts
        else { return }
        var result: [NFTCollectionNFTItem] = []
        
        nfts.forEach {
            let id = $0.self
            guard let nft = allNFTItems.first(where: { $0.id == "\(id)" }),
                  let image = nft.images.first
            else { return }
            
            let liked = nftsLiked.likes.filter { $0 == id }.count > 0 ? true : false
            let inCart = nftsInCart.nfts.filter { $0 == id }.count > 0 ? true : false
            
            result.append( NFTCollectionNFTItem(id: id, image: image, rating: nft.rating, name: nft.name, price: converter.convertUSD(to: .ETH, amount: nft.price), liked: liked, inCart: inCart) )
        }
        
        nftCollectionItems = result
        nftCollectionItemsCount = result.count
        onNFTItemsUpdate?()
    }
}
