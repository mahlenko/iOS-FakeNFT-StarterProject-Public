import Foundation

struct AnyRequest: NetworkRequest {
    var endpoint: URL?
}

struct NFTCollection: Codable {
    let createdAt: String
    let name: String
    let cover: String
    let nfts: [Int]
    let description: String
    let author: Int
    let id: String
}

struct NFTCollectionListItem {
    let id: Int
    let name: String
    let cover: String
    let nftsCount: Int
}

struct NFTCollectionAuthor: Codable {
    let name: String
    let website: String
}
/*
struct NFTCollectionNFTItem {
    let id: Int
    let image: String
    let rating: Int
    let name: String
    let price: Double
    let liked: Bool
    let inCart: Bool
}

struct NFTCollectionView {
    let cover: String
    let name: String
    let website: String
    let description: String
    let nfts: [NFTCollectionNFTItem]
}
*/
