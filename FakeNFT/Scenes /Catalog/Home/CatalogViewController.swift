import UIKit
import ProgressHUD

final class CatalogViewController: UIViewController {
    var viewModel: CatalogViewModelProtocol
    private let navBar = UINavigationBar()
    private let collectionsTableView = ContentSizedTableView()
    
    init(viewModel: CatalogViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupNavigationBar()
        setupUI()
        configureTable()
        setupConstraints()
        bind()
        viewModel.getNFTCollections()
    }
    
    private func setupNavigationBar() {
        let button = UIBarButtonItem(image: UIImage(named: "Sort"), style: .plain, target: self, action: #selector(showSortingMenu))
        button.tintColor = .black
        navigationItem.rightBarButtonItem = button
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(navBar)
        view.addSubview(collectionsTableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            collectionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            collectionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureTable() {
        collectionsTableView.translatesAutoresizingMaskIntoConstraints = false
        collectionsTableView.register(CatalogCell.self, forCellReuseIdentifier: CatalogCell.reuseIdentifier)
        collectionsTableView.separatorInset = UIEdgeInsets.zero
        collectionsTableView.layoutMargins = UIEdgeInsets.zero
        collectionsTableView.dataSource = self
        collectionsTableView.delegate = self
    }
    
    func bind() {
        viewModel.onNFTCollectionsUpdate = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                self?.collectionsTableView.reloadData()
            }
        }
        
        viewModel.updateLoadingStatus = {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                /*if self.itemsTableView.refreshControl?.isRefreshing == true {
                    return self.refreshShowLoading(self.viewModel.isLoading)
                }*/

                self.defaultShowLoading(self.viewModel.isLoading)
            }
        }
        
        viewModel.showAlertClosure = {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                let titleText = "Упс! У нас ошибка."
                let messageText = self.viewModel.errorMessage ?? "Unknown error"

                let alert = RepeatAlertMaker.make(title: titleText, message: messageText) {
                    self.viewModel.getNFTCollections()
                }

                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func showSortingMenu() {
        let sortMenu = UIAlertController(title: "Сортировка", message: nil, preferredStyle: .actionSheet)
        
        sortMenu.addAction(UIAlertAction(title: "По названию", style: .default , handler:{ [weak self] (UIAlertAction) in
            self?.viewModel.sortNFTCollections(by: .name)
            }))
        sortMenu.addAction(UIAlertAction(title: "По количеству NFT", style: .default , handler:{ [weak self] (UIAlertAction) in
            self?.viewModel.sortNFTCollections(by: .nftCount)
            }))
        sortMenu.addAction(UIAlertAction(title: "Закрыть", style: .cancel))

        present(sortMenu, animated: true)
    }
    
    private func defaultShowLoading(_ isLoading: Bool) {
        if isLoading {
            ProgressHUD.show()
        } else {
            ProgressHUD.dismiss()
        }

        view.isUserInteractionEnabled = !isLoading
    }
}

extension CatalogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.NFTCollectionsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CatalogCell.reuseIdentifier, for: indexPath) as? CatalogCell,
              let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        else { return CatalogCell() }
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0)
        cell.viewModel = cellViewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        213
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let collectionId = viewModel.getCellViewModel(at: indexPath)?.id else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        guard let networkClient = viewModel.model.networkClient else { return }
            
        let collectionViewModel = CollectionViewModel(
            model: CollectionModel(
                networkClient: networkClient
            ),
            nftCollectionId: collectionId,
            converter: FakeConvertService()
        )
        
        navigationController?.pushViewController(CollectionViewController(viewModel: collectionViewModel), animated: true)
        
    }
}
