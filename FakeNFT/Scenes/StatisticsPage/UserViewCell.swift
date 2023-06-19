import UIKit
import Kingfisher

final class UserViewCell: UITableViewCell {
    private var viewModel: UserViewCellViewModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func configure(with viewModel: UserViewCellViewModel) {
        self.viewModel = viewModel
        indexView.text = viewModel.index
        nameView.text = viewModel.name
        countView.text = viewModel.count

        if let avatarURL = viewModel.avatarURL {
            let placeholderImage = UIImage(named: "avatar")
            avatarView.kf.setImage(with: avatarURL, placeholder: placeholderImage)
        } else {
            avatarView.image = UIImage(named: "avatar")
        }

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        indexView.text = nil
        nameView.text = nil
        countView.text = nil
    }

    private lazy var nameView: UILabel = {
        let label = UILabel()
        label.textColor = .asset(.black)
        label.font = .headline3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var countView: UILabel = {
        let label = UILabel()
        label.textColor = .asset(.black)
        label.font = .headline3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var indexView: UILabel = {
        let label = UILabel()
        label.textColor = .asset(.black)
        label.font = .caption1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = .asset(.lightGray)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var avatarView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false

        // Задаем размер изображения
        let imageSize = CGSize(width: 28, height: 28)
        view.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true

        // Задаем форму в виде круга
        view.layer.cornerRadius = imageSize.width / 2
        view.clipsToBounds = true

        return view
    }()
}

// MARK: - Appearance
private extension UserViewCell {
    func setupAppearance() {
        backgroundColor = .clear
        selectionStyle = .none

        addSubview(indexView)
        addSubview(nameView)
        addSubview(countView)
        addSubview(avatarView)
        insertSubview(backView, at: 0)

        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            backView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            indexView.centerYAnchor.constraint(equalTo: centerYAnchor),
            indexView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            indexView.topAnchor.constraint(equalTo: topAnchor, constant: 26.5),
            indexView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -26.5),

            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16),

            nameView.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            nameView.topAnchor.constraint(equalTo: topAnchor, constant: 26.5),
            nameView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -26.5),

            countView.centerYAnchor.constraint(equalTo: centerYAnchor),
            countView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16),
            countView.topAnchor.constraint(equalTo: topAnchor, constant: 26.5),
            countView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -26.5)
        ])
    }
}
