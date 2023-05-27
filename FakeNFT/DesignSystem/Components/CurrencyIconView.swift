//
// Created by Сергей Махленко on 25.05.2023.
//

import UIKit

final class CurrencyIconView: ImageWithLoadingView {
    override init(url: URL?) {
        super.init(url: url)

        layer.cornerRadius = 6
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func load(url: URL?) {
        super.load(url: url) {
            self.backgroundColor = .asset(.blackUniversal)
        }
    }
}
