//
//  MyNFTViewController.swift
//  FakeNFT
//

import UIKit
import ProgressHUD
import Kingfisher

final class MyNFTViewController: UIViewController {

    private let nftsViewModel: NFTsViewModelProtocol
    private let errorAlertPresenter: ErrorAlertPresenter

    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.myNFTStubLabelText
        label.font = UIFont.systemFont(ofSize: 17, weight:  .bold)
        label.textColor = .asset(.black)
        label.isHidden = nftsViewModel.stubLabelIsHidden
        return label
    }()

    private lazy var nftTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(MyNFTTableViewCell.self)
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.backgroundColor = .asset(.white)
        return tableView
    }()

    init(nftsViewModel: NFTsViewModelProtocol) {
        self.nftsViewModel = nftsViewModel
        self.errorAlertPresenter = ErrorAlertPresenter()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        errorAlertPresenter.viewController = self
        setupNavigationController()
        setupConstraints()
        setupController()
        bind()
        nftsViewModel.needUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        KingfisherManager.shared.downloader.cancelAll()
    }

    private func bind() {
        nftsViewModel.nftViewModelsObservable.bind { [weak self] _ in
            guard let self = self else { return }
            self.nftTableView.performBatchUpdates {
                self.nftTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                self.stubLabel.isHidden = self.nftsViewModel.stubLabelIsHidden
            }
        }
        nftsViewModel.isNFTsDownloadingNowObservable.bind { isNFTsDownloadingNow in
            isNFTsDownloadingNow ? UIBlockingProgressHUD.show() : UIBlockingProgressHUD.dismiss()
        }
        nftsViewModel.nftsReceivingErrorObservable.bind { [weak self] error in
            self?.errorAlertPresenter.showAlert(title: L10n.networkErrorAlertTitle,
                                                message: String(format: L10n.networkErrorAlertMessage, error),
                                                firstActionTitle: L10n.networkErrorAlertFirstActionTitle,
                                                secondActionTitle: L10n.networkErrorAlertSecondActionTitle) {
                self?.nftsViewModel.needUpdate()
            } secondAction: {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func setupController() {
        view.backgroundColor = .asset(.white)
        title = nftsViewModel.myNFTsTitle
    }

    private func setupNavigationController() {
        let rightButton = UIBarButtonItem(image: .asset(.sort),
                                          style: .plain,
                                          target: self,
                                          action: #selector(sortMyNFTAction))
        navigationItem.rightBarButtonItem = rightButton
    }

    @objc private func sortMyNFTAction() {
        let sortAlert = UIAlertController(title: nil, message: L10n.sortingAlertTitle, preferredStyle: .actionSheet)
        let sortByPriceAction = UIAlertAction(title: L10n.sortByPriceString, style: .default) { [weak self] _ in
            self?.nftsViewModel.myNFTSorted(by: .price)
        }
        let sortByRatingAction = UIAlertAction(title: L10n.sortByRatingString, style: .default) { [weak self] _ in
            self?.nftsViewModel.myNFTSorted(by: .rating)
        }
        let sortByNameAction = UIAlertAction(title: L10n.sortByNameString, style: .default) { [weak self] _ in
            self?.nftsViewModel.myNFTSorted(by: .name)
        }
        let closeAction = UIAlertAction(title: L10n.closeButtonTitle, style: .cancel)
        [sortByPriceAction, sortByRatingAction, sortByNameAction, closeAction].forEach { sortAlert.addAction($0) }
        present(sortAlert, animated: true)
    }

    private func setupConstraints() {
        [nftTableView, stubLabel].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            nftTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            nftTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nftTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            nftTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension MyNFTViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nftsViewModel.nftViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyNFTTableViewCell = tableView.dequeueReusableCell()
        cell.configCell(from: nftsViewModel.nftViewModels[indexPath.row])
        return cell
    }
}
