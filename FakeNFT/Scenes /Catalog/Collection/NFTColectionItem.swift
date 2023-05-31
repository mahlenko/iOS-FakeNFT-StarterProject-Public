import UIKit
import Kingfisher

final class NFTColectionItem: UICollectionViewCell {
    static let reuseIdentifier = "nftColectionItem"
    
    var viewModel: NFTCollection? {
        didSet {
            guard let viewModel = viewModel else { return }
            //collectionName.text = "\(viewModel.name) (\(viewModel.nftsCount))"
            
            if let url = URL(string: viewModel.cover.encodeUrl) {
                nftImage.kf.setImage(with: url)
            }
        }
    }
    
    private var nftImage: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        //setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.backgroundColor = .blue
        //contentView.addSubview(nftImage)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 108),
            //nftImage.widthAnchor.constraint(equalToConstant: 0)
            //nftImage.heightAnchor.constraint(equalToConstant: 108),
            
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //nftImage.kf.cancelDownloadTask()
    }
}
