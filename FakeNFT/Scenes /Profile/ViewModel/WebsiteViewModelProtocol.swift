//
//  WebsiteViewModelProtocol.swift
//  FakeNFT
//

import Foundation

protocol WebsiteViewModelProtocol: ViewModelProtocol {
    var websiteURLString: String { get }
    var websiteURLRequest: URLRequest { get }
    var progressValueObservable: Observable<Float> { get }
    var shouldHideProgress: Bool { get }
    func received(_ newProgressValue: Double)
    func needUpdate()
}

extension WebsiteViewModelProtocol {
    func needUpdate() {   }
}
