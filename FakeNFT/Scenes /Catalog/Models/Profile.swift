import Foundation

struct Profile: Codable {
    let avatar: String
    let name: String
    let description: String
    let website: String
    let nfts: [Int]
    let likes: [Int]
    let id: String
}
