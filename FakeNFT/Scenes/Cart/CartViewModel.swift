//
// Created by Сергей Махленко on 02.06.2023.
//

import Foundation

final class CartViewModel: NetworkViewModel {

    var order: Order?

    var reloadTableViewClosure: (() -> Void)?

    var removeTableCellClosure: ((_ indexPath: IndexPath) -> Void)?

    private var cellViewModels: [Nft] = []

    var numberOfCells: Int {
        cellViewModels.count
    }

    var totalPriceCells: String {
        String(format: "%.02f", cellViewModels.reduce(0) { $0 + $1.price })
    }

    // MARK: - Methods ViewModel

    func getCellViewModel(at indexPath: IndexPath) -> Nft {
        cellViewModels[indexPath.row]
    }

    func sort(by: SortType) {
        cellViewModels.sort { (lhs: Nft, rhs: Nft) -> Bool in
            switch by {
            case .name: return lhs.name < rhs.name
            case .price: return lhs.price < rhs.price
            case .rating: return lhs.rating < rhs.rating
            }
        }
    }

    func removeCellViewModel(at indexPath: IndexPath) {
        cellViewModels.remove(at: indexPath.row)
        removeTableCellClosure?(indexPath)
    }

    func fetchOrder(id: String) {
        isLoading = true
        order = nil

        networkClient.send(request: GetOrderRequest(id: id), type: Order.self) { [weak self] (result: Result<Order, Error>) in
            guard let self else { return }

            switch result {
            case .success(let order):
                self.order = order

                if order.nfts.count > 0 {
                    let dispatchGroup = DispatchGroup()

                    var cells:[Nft] = []
                    order.nfts.forEach { id in
                        dispatchGroup.enter()
                        DispatchQueue.main.async {
                            self.fetchNft(id: id) { nft in
                                cells.append(nft)
                                dispatchGroup.leave()
                            }
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        self.cellViewModels = cells
                        self.isLoading = false
                        self.reloadTableViewClosure?()
                    }

                } else {
                    self.cellViewModels = []
                    self.isLoading = false
                    self.reloadTableViewClosure?()
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // TODO: Кажется это должно быть в другой модели, а с другой стороны это часть заказа
    private func fetchNft(id: String, onResponse: @escaping (_ nft: Nft) -> Void ) {
        networkClient.send(request: GetNftRequest(id: id), type: Nft.self) { [weak self] (result: Result<Nft, Error>) in
            switch result {
            case .success(let nft):
                onResponse(nft)
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
}
