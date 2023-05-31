import Foundation

protocol CatalogModelProtocol {
    func getNFTCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void)
}

final class CatalogModel: CatalogModelProtocol {
    var networkClient: DefaultNetworkClient?
    
    init(networkClient: DefaultNetworkClient) {
        self.networkClient = networkClient
    }
    
    func getNFTCollections(completion: @escaping (Result<[NFTCollection], Error>) -> Void) {
        guard let networkClient = networkClient,
              let url = URL(string: "https://64611c69491f9402f49ecce1.mockapi.io/api/v1/collections")
        else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }
        let request = AnyRequest(endpoint: url)
        networkClient.send(request: request, type: [NFTCollection].self) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
