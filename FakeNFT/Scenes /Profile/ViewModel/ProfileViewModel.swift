//
//  ProfileViewModel.swift
//  FakeNFT
//

import Foundation

enum ProfileOption: Int {
    case myNFT, favoritesNFT, website, editProfile, mainProfile
}

enum ProfileReceivingError: Error {
    case userNotAuthorized
}

final class ProfileViewModel {

    private let profileStore: ProfileStoreProtocol
    private let userIDStorage: UserIDStorageProtocol

    @Observable
    private(set) var name: String
    @Observable
    private(set) var mainAvatarURL: URL?
    @Observable
    private var editedAvatarURL: URL?
    @Observable
    private(set) var description: String
    @Observable
    private(set) var website: String
    @Observable
    private(set) var nfts: [Int]
    @Observable
    private(set) var likes: [Int]
    @Observable
    private var isProfileUpdatingNow: Bool
    @Observable
    private var profileReceivingError: String
    @Observable
    private var isNeedEditingWebsite: Bool
    @Observable
    private var isNeedEditingProfile: Bool
    @Observable
    private var isNeedEditingProfileFields: Bool
    @Observable
    private var shouldShowURLValidationAlert: Bool
    @Observable
    private var shouldShowEmptyProfileAlert: Bool
    @Observable
    private var isAllowShowWebsite: Bool
    @Observable
    private var isAvatarUploadingAllow: Bool
    @Observable
    private var myNFTsViewModel: NFTsViewModelProtocol?
    @Observable
    private var favoritesNFTsViewModel: NFTsViewModelProtocol?
    @Observable
    private var editProfileViewModel: ProfileViewModelProtocol?
    @Observable
    private var websiteViewModel: WebsiteViewModelProtocol?

    private var userID: String
    private var didUserCancelValidation: Bool

    private lazy var viewModelCompletion: ((Result<ProfileModel, Error>) -> Void) = { [weak self] result in
        self?.isProfileUpdatingNow = false
        switch result {
        case .success(let profile): self?.setProfileViewModel(from: profile)
        case .failure(let error): self?.handle(error)
        }
    }

    private var profileOption: ProfileOption {
        didSet {
            switch profileOption {
            case .mainProfile: resetChildViewModels()
            case .myNFT: myNFTsViewModel = NFTsViewModel(for: nfts, profileViewModel: self)
            case .favoritesNFT: favoritesNFTsViewModel = NFTsViewModel(for: likes, profileViewModel: self)
            case .editProfile: editProfileViewModel = self
            case .website:
                if isUserWebsiteValid {
                    websiteViewModel = WebsiteViewModel(websiteURLString: website)
                } else {
                    isAllowShowWebsite = false
                    didSelect(.mainProfile)
                }
            }
        }
    }

    private var avatarURLString: String {
        if let url = editedAvatarURL {
            return url.absoluteString
        } else {
            if let url = mainAvatarURL {
                return url.absoluteString
            } else {
                preconditionFailure("Unable to get website URL string")
            }
        }
    }

    private var isUserWebsiteValid: Bool {
        isUserURLValid(urlString: website)
    }

    init(profileStore: ProfileStoreProtocol = ProfileStore(),
         userIDStorage: UserIDStorageProtocol = UserIDStorage()) {
        self.profileStore = profileStore
        self.userIDStorage = userIDStorage
        self.userID = ""
        self.name = ""
        self.description = ""
        self.website = ""
        self.nfts = []
        self.likes = []
        self.profileReceivingError = ""
        self.isProfileUpdatingNow = false
        self.isNeedEditingWebsite = false
        self.isNeedEditingProfile = false
        self.isNeedEditingProfileFields = false
        self.shouldShowURLValidationAlert = false
        self.shouldShowEmptyProfileAlert = false
        self.isAllowShowWebsite = false
        self.didUserCancelValidation = false
        self.isAvatarUploadingAllow = false
        self.profileOption = .mainProfile
    }

    private func setProfileViewModel(from profileModel: ProfileModel) {
        guard profileModel.id == userIDStorage.userID else {
            handle(ProfileReceivingError.userNotAuthorized)
            return
        }
        userID = profileModel.id
        name = profileModel.name
        mainAvatarURL = URL(string: profileModel.avatar)
        description = profileModel.description
        website = profileModel.website
        nfts = profileModel.nfts
        likes = profileModel.likes
        myNFTsViewModel?.nftsUpdated(newNFTs: nfts)
        favoritesNFTsViewModel?.nftsUpdated(newNFTs: likes)
    }

    private func handle(_ error: Error) {
        resetProfileViewModel()
        profileReceivingError = String(format: L10n.profileReceivingError, error as CVarArg)
    }

    private func resetProfileViewModel() {
        name = ""
        description = ""
        website = ""
        mainAvatarURL = nil
        nfts = []
        likes = []
    }

    private func isUserURLValid(urlString: String?) -> Bool {
        guard profileOption == .website || profileOption == .editProfile else { return true }
        let urlRegEx = Constants.urlRegEx
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: urlString)
        return result
    }

    private func resetChildViewModels() {
        myNFTsViewModel = nil
        favoritesNFTsViewModel = nil
        websiteViewModel = nil
        editProfileViewModel = nil
    }
}

// MARK: - ProfileViewModelProtocol

extension ProfileViewModel: ProfileViewModelProtocol {

    var nameObservable: Observable<String> { $name }
    var mainAvatarURLObservable: Observable<URL?> { $mainAvatarURL }
    var editedAvatarURLObservable: Observable<URL?> { $editedAvatarURL }
    var descriptionObservable: Observable<String> { $description }
    var websiteObservable: Observable<String> { $website }
    var nftsObservable: Observable<[Int]> { $nfts }
    var likesObservable: Observable<[Int]> { $likes }
    var isProfileUpdatingNowObservable: Observable<Bool> { $isProfileUpdatingNow }
    var profileReceivingErrorObservable: Observable<String> { $profileReceivingError }
    var shouldShowURLValidationAlertObservable: Observable<Bool> { $shouldShowURLValidationAlert }
    var shouldShowEmptyProfileAlertObservable: Observable<Bool> { $shouldShowEmptyProfileAlert }
    var isNeedEditingWebsiteObservable: Observable<Bool> { $isNeedEditingWebsite }
    var isNeedEditingProfileObservable: Observable<Bool> { $isNeedEditingProfile }
    var isAllowShowWebsiteObservable: Observable<Bool> { $isAllowShowWebsite }
    var isAvatarUploadingAllowObservable: Observable<Bool> { $isAvatarUploadingAllow }
    var myNFTsViewModelObservable: Observable<NFTsViewModelProtocol?> { $myNFTsViewModel }
    var favoritesNFTsViewModelObservable: Observable<NFTsViewModelProtocol?> { $favoritesNFTsViewModel }
    var editProfileViewModelObservable: Observable<ProfileViewModelProtocol?> { $editProfileViewModel }
    var websiteViewModelObservable: Observable<WebsiteViewModelProtocol?> { $websiteViewModel }
    var isNeedEditingProfileFieldsObservable: Observable<Bool> { $isNeedEditingProfileFields }

    func needUpdate() {
        isProfileUpdatingNow = true
        profileStore.fetchProfile(completion: viewModelCompletion)
    }

    func didChangeProfile(name: String?,
                          description: String?,
                          website: String?,
                          likes: [Int]?,
                          viewCompletion: @escaping () -> Void,
                          childViewModelCompletion: @escaping (() -> Void)) {
        isProfileUpdatingNow = true
        guard isUserURLValid(urlString: website) || didUserCancelValidation else {
            isProfileUpdatingNow = false
            shouldShowURLValidationAlert = true
            return
        }
        guard (name != "" && description != "") || didUserCancelValidation else {
            isProfileUpdatingNow = false
            shouldShowEmptyProfileAlert = true
            return
        }
        didUserCancelValidation = false
        let profileModel = ProfileModel(name: name ?? self.name,
                                        avatar: avatarURLString,
                                        description: description ?? self.description,
                                        website: website ?? self.website,
                                        nfts: self.nfts,
                                        likes: likes ?? self.likes,
                                        id: userID)
        profileStore.updateProfile(profileModel, viewModelCompletion, childViewModelCompletion, viewCompletion)
    }

    func localized(for profileOption: ProfileOption) -> String {
        switch profileOption {
        case .mainProfile: return L10n.profileTitle
        case .myNFT: return String(format: L10n.myNFTsTitleWithCount, nfts.count)
        case .favoritesNFT: return String(format: L10n.favoritesNFTsTitleWithCount, likes.count)
        case .website: return L10n.websiteTitle
        case .editProfile: return L10n.editProfileTitle
        }
    }

    func profileOption(for cellRow: Int) -> ProfileOption {
        guard let profileOption = ProfileOption(rawValue: cellRow) else {
            preconditionFailure("Error: unable to get profile option by rawValue")
        }
        return profileOption
    }

    func didSelect(_ profileOption: ProfileOption) {
        self.profileOption = profileOption
    }

    func didTapEditWebsite() {
        if profileOption == .mainProfile { isNeedEditingProfile = true }
        if profileOption == .editProfile { isNeedEditingWebsite = true }
    }

    func didTapEditProfile() {
        isNeedEditingProfileFields = true
    }

    func didTapContinue() {
        if profileOption == .editProfile {
            didUserCancelValidation = true
            if isUserWebsiteValid {
                shouldShowEmptyProfileAlert = false
            } else {
                shouldShowURLValidationAlert = false
            }
        }
    }

    func didTapWebsiteButton() {
        isAllowShowWebsite = isUserWebsiteValid ? true : false
    }

    func didTapChangeAvatarButton() {
        isAvatarUploadingAllow = true
    }

    func didFakeUploadingAvatar(urlString: String) {
        isProfileUpdatingNow = true
        editedAvatarURL = URL(string: urlString)
    }

    func didLoadAvatar() {
        isProfileUpdatingNow = false
        isAvatarUploadingAllow = false
    }
}
