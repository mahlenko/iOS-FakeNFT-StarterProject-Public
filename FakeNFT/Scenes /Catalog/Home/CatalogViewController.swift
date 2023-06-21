import UIKit
import ProgressHUD

final class CatalogViewController: UIViewController {
    var viewModel: CatalogViewModelProtocol
    private let collectionsTableView = ContentSizedTableView()
    
    lazy private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadNFTCollections), for: .valueChanged)
        return refreshControl
    }()
    
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
        loadNFTCollections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl.endRefreshing()
    }
    
    lazy private var sortButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: .asset(.sort),
            style: .plain,
            target: self,
            action: #selector(showSortingMenu))
        button.tintColor = .asset(.black)
        return button
    }()
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func setupUI() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorAnimation = .asset(.black)

        collectionsTableView.backgroundColor = .asset(.white)
        collectionsTableView.refreshControl = refreshControl
        
        view.backgroundColor = .asset(.white)
        navigationController?.navigationBar.tintColor = .asset(.black)
        view.addSubview(collectionsTableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
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
                self?.refreshControl.endRefreshing()
            }
        }
        
        viewModel.updateLoadingStatus = {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.defaultShowLoading(self.viewModel.isLoading)
            }
        }
        
        viewModel.showAlertClosure = {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                let alert = RepeatAlertMaker.make(
                    title: Strings.errorMessageTitle,
                    message: self.viewModel.errorMessage ?? Strings.unknownError,
                    repeatHandle: { [weak self] in
                        self?.viewModel.getNFTCollections()
                        
                    }, cancelHandle: { [weak self] in
                        self?.viewModel.isLoading = false
                        self?.refreshControl.endRefreshing()
                    }
                )
                
                self.present(alert, animated: true)
            }
        }
    }
    
    @objc private func showSortingMenu() {
        let sortMenu = UIAlertController(title: Strings.sorting, message: nil, preferredStyle: .actionSheet)
        
        sortMenu.addAction(UIAlertAction(title: Strings.sortByName, style: .default , handler:{ [weak self] (UIAlertAction) in
            self?.viewModel.sortNFTCollections(by: .name)
            }))
        sortMenu.addAction(UIAlertAction(title: Strings.sortByNFTCount, style: .default , handler:{ [weak self] (UIAlertAction) in
            self?.viewModel.sortNFTCollections(by: .nftCount)
            }))
        sortMenu.addAction(UIAlertAction(title: Strings.close, style: .cancel))

        present(sortMenu, animated: true)
    }
    
    private func defaultShowLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                ProgressHUD.show()
            } else {
                ProgressHUD.dismiss()
            }
        }

        view.isUserInteractionEnabled = !isLoading
    }
    
    @objc private func loadNFTCollections() {
        viewModel.getNFTCollections()
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
        187
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let collectionId = viewModel.getCellViewModel(at: indexPath)?.id else { return }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.tintColor = .asset(.white)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let collectionViewModel = CollectionViewModel(
            networkClient: viewModel.networkClient,
            nftCollectionId: collectionId,
            converter: FakeConvertService()
        )
        
        let colectionViewController = CollectionViewController(viewModel: collectionViewModel)
        colectionViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(colectionViewController, animated: true)
    }
}
