import UIKit

final class NFTItemCell: UICollectionViewCell {
    static let reuseIdentifier = "nftItemCell"
    
    private var cartTapHandle: (() -> Void)?
    private var likeTapHandle: (() -> Void)?
    var viewModel: NFTCollectionNFTItem? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            if let url = URLEncoder(url: viewModel.image).encodedURL {
                nftImage.load(url: url)
            }
            nftRatingView.set(length: viewModel.rating)
            nftName.text = viewModel.name
            nftPrice.text = viewModel.price.removeZerosFromEnd() + " " + CryptoCoin.ETH.rawValue
            
            if viewModel.liked {
                likeButton.setImage(UIImage(named: "likeIcon"), for: .normal)
            } else {
                likeButton.setImage(UIImage(named: "noLikeIcon"), for: .normal)
            }
            
            if viewModel.inCart {
                cartButton.setImage(UIImage(named: "removeFromCart"), for: .normal)
            } else {
                cartButton.setImage(UIImage(named: "addToCart"), for: .normal)
            }
        }
    }
    
    private let nftImage: ImageViewWithPreloading = {
        let view = ImageViewWithPreloading()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let nftRatingView = RatingView()
    
    private let nftNameAndPriceView = UIViewAutoLayout()
    
    private let nftName = StylizedLabel(style: .nftCollectionNameInNFTCollectionList)
    private let nftPrice = StylizedLabel(style: .priceInNFTCell)
    
    lazy private var cartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addToCart"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCart), for: .touchUpInside)
        return button
    }()
    
    lazy private var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "likeIcon"), for: .normal)
        button.imageView?.tintColor = .asset(.red)
        button.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(nftImage)
        contentView.addSubview(nftRatingView)
        contentView.addSubview(nftNameAndPriceView)
        nftNameAndPriceView.addSubview(nftName)
        nftNameAndPriceView.addSubview(nftPrice)
        contentView.addSubview(cartButton)
        contentView.addSubview(likeButton)
        
        nftRatingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nftImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImage.heightAnchor.constraint(equalTo: nftImage.widthAnchor),
            
            nftRatingView.topAnchor.constraint(equalTo: nftImage.bottomAnchor, constant: 8),
            nftRatingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftRatingView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            nftRatingView.bottomAnchor.constraint(equalTo: nftRatingView.topAnchor, constant: 12),
            
            nftNameAndPriceView.topAnchor.constraint(equalTo: nftRatingView.bottomAnchor, constant: 5),
            nftNameAndPriceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftNameAndPriceView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.63),
            nftNameAndPriceView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            nftName.topAnchor.constraint(equalTo: nftNameAndPriceView.topAnchor),
            nftName.leadingAnchor.constraint(equalTo: nftNameAndPriceView.leadingAnchor),
            nftName.trailingAnchor.constraint(lessThanOrEqualTo: nftNameAndPriceView.trailingAnchor),
            
            nftPrice.bottomAnchor.constraint(equalTo: nftNameAndPriceView.bottomAnchor),
            nftPrice.leadingAnchor.constraint(equalTo: nftNameAndPriceView.leadingAnchor),
            nftPrice.trailingAnchor.constraint(lessThanOrEqualTo: nftNameAndPriceView.trailingAnchor),
            
            cartButton.centerYAnchor.constraint(equalTo: nftNameAndPriceView.centerYAnchor),
            cartButton.leadingAnchor.constraint(greaterThanOrEqualTo: nftNameAndPriceView.trailingAnchor),
            cartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            likeButton.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImage.kf.cancelDownloadTask()
        nftImage.image = nil
    }
    
    func setup(cartTapHandle: (() -> Void)? = nil, likeTapHandle: @escaping (() -> Void)) {
        self.cartTapHandle = cartTapHandle
        self.likeTapHandle = likeTapHandle
    }
    
    @objc private func didTapCart() {
        cartTapHandle?()
    }
    
    @objc private func didTapLike() {
        likeTapHandle?()
    }
}
