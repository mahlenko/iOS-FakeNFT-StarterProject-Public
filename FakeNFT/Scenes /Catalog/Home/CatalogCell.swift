import UIKit
import Kingfisher

final class CatalogCell: UITableViewCell {
    static let reuseIdentifier = "CatalogTableCell"
    
    var viewModel: NFTCollectionListItem? {
        didSet {
            guard let viewModel = viewModel else { return }
            collectionName.text = "\(viewModel.name) (\(viewModel.nftsCount))"
            
            guard let url = URLEncoder(url: viewModel.cover).encodedURL else { return }
            collectionImage.kf.setImage(with: url)
        }
    }
    
    private var collectionImage: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let collectionNameView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let collectionName = StylizedLabel(style: .nftCollectionNameInNFTCollectionList)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell() {
        contentView.addSubview(collectionImage)
        contentView.addSubview(collectionNameView)
        collectionNameView.addSubview(collectionName)
        
        NSLayoutConstraint.activate([
            collectionImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionImage.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: 140),
            
            collectionNameView.topAnchor.constraint(equalTo: collectionImage.bottomAnchor, constant: 4),
            collectionNameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionNameView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            collectionNameView.bottomAnchor.constraint(equalTo: collectionImage.bottomAnchor, constant: 28),
            
            collectionName.leadingAnchor.constraint(equalTo: collectionNameView.leadingAnchor),
            collectionName.trailingAnchor.constraint(equalTo: collectionNameView.trailingAnchor),
            collectionName.centerYAnchor.constraint(equalTo: collectionNameView.centerYAnchor),
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews where view != contentView {
            view.removeFromSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionImage.kf.cancelDownloadTask()
        collectionImage.image = nil
    }
}
