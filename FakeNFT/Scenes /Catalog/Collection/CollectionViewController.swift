import UIKit
import ProgressHUD

final class CollectionViewController: UIViewController {
    var viewModel: CollectionViewModelProtocol
    
    private let contentView = UIViewAutoLayout()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
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
    
    private let collectionNameView = UIViewAutoLayout()
    private let collectionNameLabel = LineHeightedLabel(lineHeight: 28, withFont: UIFont.nftCollectionName, color: .asset(.black))
    private let authorView = UIViewAutoLayout()
    private let collectionAuthorNameLabel = LineHeightedLabel(lineHeight: 20, withFont: UIFont.nftAuthor, color: .asset(.blue), enabledUserInteraction: true)
    private let collectionDescriptionLabel = LineHeightedLabel(lineHeight: 3, withFont: UIFont.nftDescription, color: .asset(.black), linesCount: 0)
    
    private let collectionAuthorLabel: UILabel = {
        let label = UILabel()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 18
        let attrString = NSMutableAttributedString(string: Strings.nftCollectionAuthor)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.nftDescription, range: NSMakeRange(0, attrString.length))
        label.attributedText = attrString
        
        label.textColor = .asset(.black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nftItemsCollectionView = ContentSizedCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    init(viewModel: CollectionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nftItemsCollectionView.register(NFTItemCell.self, forCellWithReuseIdentifier: NFTItemCell.reuseIdentifier)
        nftItemsCollectionView.backgroundColor = .asset(.white)
        nftItemsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        nftItemsCollectionView.dataSource = self
        nftItemsCollectionView.delegate = self
        
        setupUI()
        setupConstraints()
        bind()
        
        viewModel.getNFTCollectionInfo()
    }

    func bind() {
        viewModel.onNFTCollectionInfoUpdate = { [weak self] in
            guard let self = self else { return }
            self.updateNFTCollectionDetails()
        }
        viewModel.onNFTAuthorUpdate = { [weak self] in
            guard let self = self else { return }
            self.updateNFTCollectionAuthor()
        }
        viewModel.onNFTItemsUpdate = { [weak self] in
            guard let self = self else { return }
            self.updateNFTCollectionItems()
            self.viewModel.isLoading = false
        }
        viewModel.updateLoadingStatus = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.defaultShowLoading(self.viewModel.isLoading)
            }
        }
        viewModel.showAlertClosure = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                let alert = RepeatAlertMaker.make(
                    title: Strings.errorMessageTitle,
                    message: self.viewModel.errorMessage ?? Strings.unknownError,
                    repeatHandle: { [weak self] in
                        self?.viewModel.getNFTCollectionInfo()
                    }, cancelHandle: { [weak self] in
                        self?.viewModel.isLoading = false
                    }
                )

                self.present(alert, animated: true)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .asset(.white)
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
        var topbarHeight: CGFloat {
            return (navigationController?.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                (self.navigationController?.navigationBar.frame.height ?? 0.0)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: -topbarHeight),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
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
            collectionAuthorNameLabel.leadingAnchor.constraint(greaterThanOrEqualTo: collectionAuthorLabel.trailingAnchor, constant: 4),
            collectionAuthorNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: authorView.trailingAnchor),
            
            collectionDescriptionLabel.topAnchor.constraint(equalTo: authorView.bottomAnchor),
            collectionDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            nftItemsCollectionView.topAnchor.constraint(equalTo: collectionDescriptionLabel.bottomAnchor, constant: 24),
            nftItemsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftItemsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftItemsCollectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            
            contentView.bottomAnchor.constraint(equalTo: nftItemsCollectionView.bottomAnchor)
        ])
    }
    
    func updateNFTCollectionDetails() {
        guard let coverURL = viewModel.nftCollection?.cover,
              let url = URLEncoder(url: coverURL).encodedURL
        else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let NFTCollection = self.viewModel.nftCollection
            else { return }
            self.collectionCover.kf.setImage(with: url)
            self.collectionNameLabel.text = NFTCollection.name
            self.collectionDescriptionLabel.text = NFTCollection.description
            self.collectionDescriptionLabel.sizeToFit()
        }
        guard let authorId = viewModel.nftCollection?.author else { return }
        viewModel.getNFTCollectionAuthor(id: authorId)
    }
    
    func updateNFTCollectionAuthor() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let NFTCollectionAuthor = self.viewModel.nftCollectionAuthor
            else { return }
            self.collectionAuthorNameLabel.text = NFTCollectionAuthor.name
        }
        viewModel.getNFTCollectionItems()
    }
    
    func updateNFTCollectionItems() {
        DispatchQueue.main.async { [weak self] in
            self?.nftItemsCollectionView.reloadData()
        }
    }
    
    @objc private func showAuthorsWebsite(sender: UITapGestureRecognizer) {
        guard let website = viewModel.nftCollectionAuthor?.website,
              let url = URLEncoder(url: website).encodedURL
        else { return }

        navigationController?.pushViewController(WebViewService(url: url), animated: true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .asset(.black)
    }
    
    private func defaultShowLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                ProgressHUD.show()
            } else {
                ProgressHUD.dismiss()
            }
        }

        view.isUserInteractionEnabled = !isLoading
    }
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.nftCollectionItemsCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NFTItemCell.reuseIdentifier, for: indexPath) as? NFTItemCell,
              let cellViewModel = viewModel.nftCollectionItems?[indexPath.row]
        else { return UICollectionViewCell() }
        
        cell.viewModel = cellViewModel
        cell.setup(
            cartTapHandle: { [weak self] in
                self?.viewModel.toggleCart(id: cellViewModel.id)
            }, likeTapHandle: { [weak self] in
                self?.viewModel.toggleLike(id: cellViewModel.id)
            }
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 28
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenHeight = view.frame.height
        let calculatedCellHeight = screenHeight * 0.21 > 192 ? 192 : screenHeight * 0.21
        let cellHeight = calculatedCellHeight < 172 ? 172 : calculatedCellHeight
        return CGSize(width: (collectionView.bounds.width / 3) - 6, height: cellHeight)
    }
}
