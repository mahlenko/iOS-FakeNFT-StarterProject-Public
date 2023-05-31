import Foundation

protocol CollectionModelProtocol {
    func getNFTCollectionInfo(id: Int, completion: @escaping (Result<NFTCollection, Error>) -> Void)
    func getNFTCollectionAuthor(id: Int, completion: @escaping (Result<NFTCollectionAuthor, Error>) -> Void)
}

final class CollectionModel: CollectionModelProtocol {
    var networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func getNFTCollectionInfo(id: Int, completion: @escaping (Result<NFTCollection, Error>) -> Void) {
        guard let url = URL(string: "https://64611c69491f9402f49ecce1.mockapi.io/api/v1/collections/\(id)")
        else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }
        
        let request = AnyRequest(endpoint: url)
        networkClient.send(request: request, type: NFTCollection.self) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getNFTCollectionAuthor(id: Int, completion: @escaping (Result<NFTCollectionAuthor, Error>) -> Void) {
        guard let url = URL(string: "https://64611c69491f9402f49ecce1.mockapi.io/api/v1/users/\(id)")
        else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }
        let request = AnyRequest(endpoint: url)
        networkClient.send(request: request, type: NFTCollectionAuthor.self) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
