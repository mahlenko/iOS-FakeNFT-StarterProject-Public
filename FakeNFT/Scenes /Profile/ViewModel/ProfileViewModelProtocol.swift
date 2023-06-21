//
//  ProfileViewModelProtocol.swift
//  FakeNFT
//

import Foundation

protocol ProfileViewModelProtocol: ViewModelProtocol, AnyObject {

    var nameObservable: Observable<String> { get }
    var mainAvatarURLObservable: Observable<URL?> { get }
    var editedAvatarURLObservable: Observable<URL?> { get }
    var descriptionObservable: Observable<String> { get }
    var websiteObservable: Observable<String> { get }
    var nftsObservable: Observable<[Int]> { get }
    var likesObservable: Observable<[Int]> { get }
    var isProfileUpdatingNowObservable: Observable<Bool> { get }
    var profileReceivingErrorObservable: Observable<String> { get }
    var shouldShowURLValidationAlertObservable: Observable<Bool> { get }
    var shouldShowEmptyProfileAlertObservable: Observable<Bool> { get }
    var isNeedEditingWebsiteObservable: Observable<Bool> { get }
    var isNeedEditingProfileObservable: Observable<Bool> { get }
    var isNeedEditingProfileFieldsObservable: Observable<Bool> { get }
    var isAllowShowWebsiteObservable: Observable<Bool> { get }
    var isAvatarUploadingAllowObservable: Observable<Bool> { get }
    var myNFTsViewModelObservable: Observable<NFTsViewModelProtocol?> { get }
    var favoritesNFTsViewModelObservable: Observable<NFTsViewModelProtocol?> { get }
    var editProfileViewModelObservable: Observable<ProfileViewModelProtocol?> { get }
    var websiteViewModelObservable: Observable<WebsiteViewModelProtocol?> { get }

    func needUpdate()
    func localized(for profileOption: ProfileOption) -> String
    func profileOption(for cellRow: Int) -> ProfileOption
    func didSelect(_ profileOption: ProfileOption)
    func didTapEditWebsite()
    func didTapEditProfile()
    func didTapContinue()
    func didTapChangeAvatarButton()
    func didFakeUploadingAvatar(urlString: String)
    func didLoadAvatar()
    func didChangeProfile(name: String?,
                          description: String?,
                          website: String?,
                          likes: [Int]?,
                          viewCompletion: @escaping () -> Void,
                          childViewModelCompletion: @escaping (() -> Void))
}
