import UIKit

final class CollectionViewController: UIViewController {
    var viewModel: CollectionViewModelProtocol?
    var nftCollectionId: Int
    var networkClient: NetworkClient
    
    private let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .green
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let collectionCover: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let collectionNameView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let collectionNameLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 28
        let attrString = NSMutableAttributedString(string: "")
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        label.attributedText = attrString
        
        label.font = CustomFont.font(name: .SFProTextBold, size: 22)
        label.textColor = UIColor.NFTBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authorView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let collectionAuthorLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 18
        let attrString = NSMutableAttributedString(string: "Автор коллекции:")
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        label.attributedText = attrString
        
        label.font = CustomFont.font(name: .SFProTextRegular, size: 13)
        label.textColor = UIColor.NFTBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionAuthorNameLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 20
        let attrString = NSMutableAttributedString(string: "")
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        label.attributedText = attrString
        
        label.font = CustomFont.font(name: .SFProTextRegular, size: 15)
        label.textColor = UIColor.NFTLinkBlue
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let collectionDescriptionLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.8
        let attrString = NSMutableAttributedString(string: "")
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        label.attributedText = attrString
        label.numberOfLines = 0
        
        label.font = CustomFont.font(name: .SFProTextRegular, size: 13)
        label.textColor = UIColor.NFTBlack
        label.backgroundColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftItemsCollectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    init(nftCollectionId: Int, networkClient: NetworkClient) {
        self.nftCollectionId = nftCollectionId
        self.networkClient = networkClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        initialize(viewModel: CollectionViewModel(model: CollectionModel(networkClient: networkClient)))
        //TODO: 🤔 наверное, лучше передать готовую структуру из родительского ViewController, чем запрашивать заново
            viewModel?.getNFTCollectionInfo(id: nftCollectionId)
        //----------
    }
    
    func initialize(viewModel: CollectionViewModelProtocol) {
        self.viewModel = viewModel
        bind()
    }
    
    func bind() {
        viewModel?.onNFTCollectionInfoUpdate = { [weak self] in
            guard let self = self else { return }
            self.updateNFTCollectionDetails()
        }
        viewModel?.onNFTAuthorUpdate = { [weak self] in
            guard let self = self else { return }
            self.updateNFTCollectionAuthor()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(collectionCover)
        contentView.addSubview(collectionNameView)
        collectionNameView.addSubview(collectionNameLabel)
        contentView.addSubview(authorView)
        authorView.addSubview(collectionAuthorLabel)
        authorView.addSubview(collectionAuthorNameLabel)
        contentView.addSubview(collectionDescriptionLabel)
        contentView.addSubview(nftItemsCollectionView)
        
        collectionAuthorNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAuthorsWebsite)))
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionCover.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionCover.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionCover.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionCover.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: 310),
            
            collectionNameView.topAnchor.constraint(equalTo: collectionCover.bottomAnchor, constant: 16),
            collectionNameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionNameView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            collectionNameView.bottomAnchor.constraint(equalTo: collectionCover.bottomAnchor, constant: 16 + 28),
            
            collectionNameLabel.centerYAnchor.constraint(equalTo: collectionNameView.centerYAnchor),
            collectionNameLabel.leadingAnchor.constraint(equalTo: collectionNameView.leadingAnchor),
            collectionNameLabel.trailingAnchor.constraint(equalTo: collectionNameView.trailingAnchor),
            
            authorView.topAnchor.constraint(equalTo: collectionNameView.bottomAnchor, constant: 8),
            authorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            authorView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            authorView.bottomAnchor.constraint(equalTo: collectionNameView.bottomAnchor, constant: 8 + 28),
            
            collectionAuthorLabel.centerYAnchor.constraint(equalTo: authorView.centerYAnchor),
            collectionAuthorLabel.leadingAnchor.constraint(equalTo: authorView.leadingAnchor),
            collectionAuthorLabel.trailingAnchor.constraint(lessThanOrEqualTo: authorView.trailingAnchor),
            
            collectionAuthorNameLabel.centerYAnchor.constraint(equalTo: authorView.centerYAnchor),
            collectionAuthorNameLabel.leadingAnchor.constraint(equalTo: collectionAuthorLabel.trailingAnchor, constant: 4),
            collectionAuthorNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: authorView.trailingAnchor),
            
            collectionDescriptionLabel.topAnchor.constraint(equalTo: authorView.bottomAnchor),
            collectionDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            nftItemsCollectionView.topAnchor.constraint(equalTo: collectionDescriptionLabel.bottomAnchor, constant: 24),
            nftItemsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftItemsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftItemsCollectionView.heightAnchor.constraint(equalToConstant: 300),
            
            contentView.bottomAnchor.constraint(equalTo: nftItemsCollectionView.bottomAnchor, constant: 20)
        ])
    }
    
    func updateNFTCollectionDetails() {
        print("updateNFTCollectionDetails called")
        guard let url = URL(string: viewModel?.NFTCollection?.cover.encodeUrl ?? "") else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let viewModel = self.viewModel,
                  let NFTCollection = viewModel.NFTCollection
            else { return }
            self.collectionCover.kf.setImage(with: url)
            self.collectionNameLabel.text = NFTCollection.name
            self.collectionDescriptionLabel.text = NFTCollection.description
            self.collectionDescriptionLabel.sizeToFit()
        }
        guard let authorId = viewModel?.NFTCollection?.author else { return }
        viewModel?.getNFTCollectionAuthor(id: authorId)
    }
    
    func updateNFTCollectionAuthor() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let viewModel = self.viewModel,
                  let NFTCollectionAuthor = viewModel.NFTCollectionAuthor
            else { return }
            self.collectionAuthorNameLabel.text = NFTCollectionAuthor.name
        }
    }
    
    @objc private func showAuthorsWebsite(sender: UITapGestureRecognizer) {
        guard let url = URL(string: viewModel?.NFTCollectionAuthor?.website.encodeUrl ?? "") else { return }
        navigationController?.pushViewController(CollectionsAuthorWebsiteViewController(website: url), animated: true)
    }
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //viewModel?.NFTItemsCount ?? 0
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NFTColectionItem.reuseIdentifier, for: indexPath) as? NFTColectionItem,
              let viewModel = viewModel,
              let cellViewModel = viewModel.NFTCollection
        else { return UICollectionViewCell() }
        
        cell.viewModel = cellViewModel
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width / 3) - 4, height: 192)
    }
}
