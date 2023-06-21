//
//  EditProfileViewController.swift
//  FakeNFT
//

import UIKit
import Kingfisher
import ProgressHUD

final class EditProfileViewController: UIViewController {

    private let profileViewModel: ProfileViewModelProtocol
    private let errorAlertPresenter: ErrorAlertPresenter
    private let notificationCenter: NotificationCenter

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        let buttonImage = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        button.setImage(buttonImage?.withTintColor(.asset(.black), renderingMode: .alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(submitChanges), for: .touchUpInside)
        return button
    }()

    private lazy var changeAvatarButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 35
        button.layer.masksToBounds = true
        let processor = OverlayImageProcessor(overlay: .asset(.black), fraction: 0.6)
        button.kf.setBackgroundImage(with: profileViewModel.mainAvatarURLObservable.wrappedValue,
                                     for: .normal,
                                     placeholder: UIImage(named: Constants.avatarPlaceholder),
                                     options: [.processor(processor)])
        button.layoutIfNeeded()
        button.subviews.first?.contentMode = .scaleAspectFill
        button.imageView?.contentMode = .scaleAspectFill
        button.setTitle(L10n.changeAvatarButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(changeAvatarAction), for: .touchUpInside)
        return button
    }()

    private lazy var loadNewAvatarButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(L10n.loadNewAvatarButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.setTitleColor(.asset(.black), for: .normal)
        button.titleLabel?.textAlignment = .center
        button.isUserInteractionEnabled = false
        button.alpha = 0.0
        button.addTarget(self, action: #selector(fakeUploadAvatarAction), for: .touchUpInside)
        return button
    }()

    private lazy var nameLabel = makeLabel(text: L10n.nameLabelText)
    private lazy var nameTextField = makeTextField(text: profileViewModel.nameObservable.wrappedValue)
    private lazy var nameStackView = makeStackView(with: [nameLabel, nameTextField])

    private lazy var descriptionLabel = makeLabel(text: L10n.descriptionLabelText)
    private lazy var descriptionTextView = makeTextView(text: profileViewModel.descriptionObservable.wrappedValue)
    private lazy var descriptionStackView = makeStackView(with: [descriptionLabel, descriptionTextView])

    private lazy var websiteLabel = makeLabel(text: L10n.websiteLabelText)
    private lazy var websiteTextField = makeTextField(text: profileViewModel.websiteObservable.wrappedValue)
    private lazy var websiteStackView = makeStackView(with: [websiteLabel, websiteTextField])

    private lazy var mainStackView = makeStackView(with: [nameStackView, descriptionStackView, websiteStackView], spacing: 24)

    // MARK: - LifeCycle

    init(profileViewModel: ProfileViewModelProtocol) {
        self.profileViewModel = profileViewModel
        self.errorAlertPresenter = ErrorAlertPresenter()
        self.notificationCenter = NotificationCenter.default
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        errorAlertPresenter.viewController = self
        setupController()
        setupConstraints()
        hideKeyboardByTap()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Pivate Funcs

    private func bind() {
        profileViewModel.shouldShowURLValidationAlertObservable.bind { [weak self] shouldShowAlert in
            if shouldShowAlert {
                self?.errorAlertPresenter.showAlert(title: L10n.validationAlertTitle,
                                                    message: L10n.validationAlertMessage,
                                                    firstActionTitle: L10n.validationAlertEditWebsiteTitle,
                                                    secondActionTitle: L10n.validationAlertContinueTitle) {
                    self?.profileViewModel.didTapEditWebsite()
                } secondAction: {
                    self?.profileViewModel.didTapContinue()
                }
            } else {
                self?.submitChanges()
            }
        }
        profileViewModel.isNeedEditingWebsiteObservable.bind { [weak self] isNeedEditingWebsite in
            if isNeedEditingWebsite {
                self?.websiteTextField.becomeFirstResponder()
            }
        }
        profileViewModel.isAvatarUploadingAllowObservable.bind { [weak self] isAvatarUploadingAllow in
            if isAvatarUploadingAllow {
                self?.loadNewAvatarButton.isUserInteractionEnabled = true
                UIView.animate(withDuration: 1) { self?.loadNewAvatarButton.alpha = 1.0 }
            } else {
                self?.loadNewAvatarButton.isUserInteractionEnabled = false
                self?.changeAvatarButton.isUserInteractionEnabled = false
                UIView.animate(withDuration: 1) { self?.loadNewAvatarButton.alpha = 0.0 }
            }

        }
        profileViewModel.editedAvatarURLObservable.bind { [weak self] url in
            self?.changeAvatarButton.kf.setImage(with: url, for: .normal,
                                                 completionHandler:  { _ in self?.profileViewModel.didLoadAvatar() })
        }
        profileViewModel.isProfileUpdatingNowObservable.bind { isProfileUpdatingNow in
            isProfileUpdatingNow ? UIBlockingProgressHUD.show() : UIBlockingProgressHUD.dismiss()
        }
        profileViewModel.shouldShowEmptyProfileAlertObservable.bind { [weak self] shouldShowAlert in
            if shouldShowAlert {
                self?.errorAlertPresenter.showAlert(title: L10n.validationAlertTitle,
                                                    message: L10n.emptyProfileFieldAlertTitle,
                                                    firstActionTitle: L10n.validationAlertEditProfileTitle,
                                                    secondActionTitle: L10n.validationAlertContinueTitle) {
                    self?.profileViewModel.didTapEditProfile()
                } secondAction: {
                    self?.profileViewModel.didTapContinue()
                }
            } else {
                self?.submitChanges()
            }
        }
        profileViewModel.isNeedEditingProfileFieldsObservable.bind { [weak self] isNeedEditingProfileFields in
            if isNeedEditingProfileFields {
                self?.nameTextField.becomeFirstResponder()
            }
        }
    }

    private func setupController() {
        view.backgroundColor = .asset(.white)
        presentationController?.delegate = self
    }

    @objc private func changeAvatarAction() {
        profileViewModel.didTapChangeAvatarButton()
    }

    @objc private func fakeUploadAvatarAction() {
        profileViewModel.didFakeUploadingAvatar(urlString: Constants.mockAvatarImageURLString)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
            scrollView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

    @objc private func keyboardWillHide() {
        scrollView.contentInset = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
    }

    @objc private func submitChanges() {
        profileViewModel.didChangeProfile(name: nameTextField.text,
                                          description: descriptionTextView.text,
                                          website: websiteTextField.text,
                                          likes: nil) { [weak self] in
            self?.dismiss(animated: true) { self?.profileViewModel.didSelect(.mainProfile) }
        } childViewModelCompletion: {   }
    }

    private func makeLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .asset(.black)
        return label
    }

    private func makeTextField(text: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = text
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textColor = .asset(.black)
        textField.backgroundColor = .asset(.lightGray)
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.enablesReturnKeyAutomatically = true
        textField.makeIndent(points: 16)
        textField.delegate = self
        return textField
    }

    private func makeTextView(text: String) -> UITextView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = .asset(.black)
        textView.backgroundColor = .asset(.lightGray)
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 11, left: 16, bottom: 11, right: 16)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    private func makeStackView(with subviews: [UIView], spacing: CGFloat = 8) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = spacing
        stackView.axis = .vertical
        return stackView
    }

    private func setupConstraints() {
        [scrollView, closeButton].forEach { view.addSubview($0) }
        scrollView.addSubview(contentView)
        [changeAvatarButton, loadNewAvatarButton, mainStackView].forEach { contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            changeAvatarButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            changeAvatarButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            changeAvatarButton.widthAnchor.constraint(equalToConstant: 70),
            changeAvatarButton.heightAnchor.constraint(equalToConstant: 70),

            loadNewAvatarButton.topAnchor.constraint(equalTo: changeAvatarButton.bottomAnchor, constant: 12),
            loadNewAvatarButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            mainStackView.topAnchor.constraint(equalTo: loadNewAvatarButton.bottomAnchor, constant: -6),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            websiteTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

// MARK: - UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return view.endEditing(true)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension EditProfileViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        submitChanges()
        return false
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        profileViewModel.didSelect(.mainProfile)
    }
}
