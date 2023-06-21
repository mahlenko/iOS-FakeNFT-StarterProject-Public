//
//  ProfileViewController.swift
//  FakeNFT
//

import UIKit
import Kingfisher
import ProgressHUD

final class ProfileViewController: UIViewController {

    private let profileViewModel: ProfileViewModelProtocol
    private let errorAlertPresenter: ErrorAlertPresenter

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.kf.indicatorType = .activity
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .asset(.black)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .asset(.black)
        label.numberOfLines = 0
        return label
    }()

    private lazy var websiteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.asset(.blue), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.setTitleColor(.asset(.blue).withAlphaComponent(0.5), for: .highlighted)
        button.addTarget(self, action: #selector(websiteButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var profileTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(ProfileTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.accessibilityIdentifier = "profileTable"
        tableView.backgroundColor = .asset(.white)
        return tableView
    }()

    // MARK: - LifeCycle

    init(profileViewModel: ProfileViewModelProtocol = ProfileViewModel(),
         errorAlertPresenter: ErrorAlertPresenter = ErrorAlertPresenter()) {
        self.profileViewModel = profileViewModel
        self.errorAlertPresenter = ErrorAlertPresenter()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .asset(.white)
        errorAlertPresenter.viewController = self
        setupNavigationController()
        setupConstraints()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profileViewModel.didSelect(.mainProfile)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        profileViewModel.needUpdate()
    }

    // MARK: - Private Funcs

    private func bind() {
        profileViewModel.nameObservable.bind { [weak self] name in
            self?.nameLabel.text = name
        }
        profileViewModel.mainAvatarURLObservable.bind { [weak self] url in
            self?.avatarImageView.kf.setImage(with: url,
                                              placeholder: UIImage(named: Constants.avatarPlaceholder))
        }
        profileViewModel.descriptionObservable.bind { [weak self] description in
            self?.descriptionLabel.text = description
        }
        profileViewModel.websiteObservable.bind { [weak self] website in
            self?.websiteButton.setTitle(website, for: .normal)
        }
        profileViewModel.nftsObservable.bind { [weak self] _ in
            self?.profileTableView.performBatchUpdates {
                self?.profileTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
        }
        profileViewModel.likesObservable.bind { [weak self] _ in
            self?.profileTableView.performBatchUpdates {
                self?.profileTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            }
        }
        profileViewModel.isProfileUpdatingNowObservable.bind { isProfileUpdatingNow in
            isProfileUpdatingNow ? UIBlockingProgressHUD.show() : UIBlockingProgressHUD.dismiss()
        }
        profileViewModel.profileReceivingErrorObservable.bind { [weak self] error in
            self?.errorAlertPresenter.showAlert(title: L10n.networkErrorAlertTitle,
                                                message: String(format: L10n.networkErrorAlertMessage, error),
                                                firstActionTitle: L10n.networkErrorAlertFirstActionTitle,
                                                secondActionTitle: L10n.networkErrorAlertSecondActionTitle) {
                self?.profileViewModel.needUpdate()
            }
        }
        profileViewModel.isAllowShowWebsiteObservable.bind { [weak self] isAllowShowWebsite in
            if isAllowShowWebsite {
                self?.profileViewModel.didSelect(.website)
            } else {
                self?.errorAlertPresenter.showAlert(title: L10n.validationAlertTitle,
                                                    message: L10n.validationAlertMessage,
                                                    firstActionTitle: L10n.validationAlertEditWebsiteTitle,
                                                    secondActionTitle: L10n.validationAlertContinueTitle) {
                    self?.profileViewModel.didTapEditWebsite()
                } secondAction: {
                    self?.profileViewModel.didTapContinue()
                }
            }
        }
        profileViewModel.isNeedEditingProfileObservable.bind { [weak self] isNeedEditingWebsite in
            self?.profileViewModel.didSelect(.editProfile)
        }
        profileViewModel.myNFTsViewModelObservable.bind { [weak self] viewModel in
            self?.pushMyNFTView(viewModel)
        }
        profileViewModel.favoritesNFTsViewModelObservable.bind { [weak self] viewModel in
            self?.pushFavoritesNFTView(viewModel)
        }
        profileViewModel.websiteViewModelObservable.bind { [weak self] viewModel in
            self?.pushWebsiteView(viewModel)
        }
        profileViewModel.editProfileViewModelObservable.bind { [weak self] viewModel in
            self?.presentProfileEditView(viewModel)
        }
    }

    private func setupNavigationController() {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let buttonImage = UIImage(systemName: "square.and.pencil", withConfiguration: imageConfig)
        let rightButton = UIBarButtonItem(image: buttonImage,
                                          style: .plain,
                                          target: self,
                                          action: #selector(editProfileButtonAction))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .asset(.black)
    }

    @objc private func websiteButtonAction() {
        profileViewModel.didSelect(.website)
    }

    @objc private func editProfileButtonAction() {
        profileViewModel.didSelect(.editProfile)
    }

    private func setupConstraints() {
        [avatarImageView, nameLabel, descriptionLabel, websiteButton, profileTableView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 13),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            websiteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            websiteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            profileTableView.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 44),
            profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func pushMyNFTView(_ viewModel: NFTsViewModelProtocol?) {
        guard let viewModel = viewModel else { return }
        let viewController = MyNFTViewController(nftsViewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func pushFavoritesNFTView(_ viewModel: NFTsViewModelProtocol?) {
        guard let viewModel = viewModel else { return }
        let viewController = FavoritesNFTViewController(nftsViewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func pushWebsiteView(_ viewModel: WebsiteViewModelProtocol?) {
        guard let viewModel = viewModel else { return }
        let url = viewModel.websiteURLString
        let viewController = WebViewService(url: url)
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func presentProfileEditView(_ viewModel: ProfileViewModelProtocol?) {
        guard let viewModel = viewModel else { return }
        let viewController = EditProfileViewController(profileViewModel: viewModel)
        present(viewController, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let profileOption = profileViewModel.profileOption(for: indexPath.row)
        profileViewModel.didSelect(profileOption)
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profileOption = profileViewModel.profileOption(for: indexPath.row)
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell()
        cell.setLabel(text: profileViewModel.localized(for: profileOption))
        cell.accessibilityIdentifier = "cell-\(indexPath.row)"
        return cell
    }
}
