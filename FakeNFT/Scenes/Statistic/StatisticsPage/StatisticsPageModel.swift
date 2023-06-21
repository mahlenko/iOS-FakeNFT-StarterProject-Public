import Foundation

final class StatisticsPageModel {
    let defaultNetworkClient = DefaultNetworkClient()

    func getUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        let request = Request(endpoint: URL(string: Config.baseUrl + "/users"), httpMethod: .get)

        defaultNetworkClient.send(request: request, type: [User].self, onResponse: completion)
    }
}
