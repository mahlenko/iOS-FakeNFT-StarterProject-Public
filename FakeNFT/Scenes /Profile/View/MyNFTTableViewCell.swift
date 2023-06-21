//
//  MyNFTTableViewCell.swift
//  FakeNFT
//

import UIKit
import Kingfisher

final class MyNFTTableViewCell: UITableViewCell, ReuseIdentifying {

    private lazy var cellStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nftImageView, nftDataStackView, nftPriceStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 20
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private lazy var nftDataStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nftNameLabel, nftRatingView, nftAuthorLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 4
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 23, left: 0, bottom: 23, right: 0)
        return stackView
    }()

    private lazy var nftPriceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nftPriceTitleLabel, nftPriceValueLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 2
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 33, left: 0, bottom: 33, right: 0)
        return stackView
    }()

    private lazy var nftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        imageView.kf.indicatorType = .activity
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var nftNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .asset(.black)
        return label
    }()
    
    private let nftRatingView = RatingView()

    private lazy var nftAuthorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSMutableAttributedString(string: L10n.fromAuthorString,
                                                         attributes: [.font: UIFont.systemFont(ofSize: 15)])
        label.textColor = .asset(.black)
        return label
    }()

    private lazy var nftPriceTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .asset(.black)
        label.text = L10n.priceTitle
        return label
    }()

    private lazy var nftPriceValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = .asset(.black)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.kf.cancelDownloadTask()
    }

    private func setupConstraints() {
        contentView.addSubview(cellStackView)
        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108)
        ])
    }

    func makeAttributedAuthorString(from authorString: String) -> NSAttributedString {
        let attributedAuthorString = NSMutableAttributedString()
        attributedAuthorString.append(NSAttributedString(string: L10n.fromAuthorString,
                                                         attributes: [.font: UIFont.systemFont(ofSize: 15)]))
        attributedAuthorString.append(NSAttributedString(string: NSLocalizedString(authorString, comment: ""),
                                                         attributes: [.font: UIFont.systemFont(ofSize: 13)]))
        return attributedAuthorString
    }

    func configCell(from nftViewModel: NFTViewModel) {
        nftImageView.kf.setImage(with: nftViewModel.image)
        nftNameLabel.text = nftViewModel.name
        nftRatingView.set(length: nftViewModel.rating)
        nftAuthorLabel.attributedText = makeAttributedAuthorString(from: nftViewModel.author)
        nftPriceValueLabel.text = nftViewModel.price
        backgroundColor = .asset(.white)
    }
}
