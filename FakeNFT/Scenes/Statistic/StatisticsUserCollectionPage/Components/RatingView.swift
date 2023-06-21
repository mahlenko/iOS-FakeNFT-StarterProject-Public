import UIKit

class RatingView: UIStackView {
    private let starSize: CGSize = CGSize(width: 12, height: 12)

    private let starImage = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)

    var rating: Int? {
        didSet {
            updateStarViews()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
    }

    private func setupStackView() {
        distribution = .fillEqually
        spacing = 2

        for _ in 0..<5 {
            let starImageView = UIImageView(image: starImage)
            starImageView.contentMode = .scaleAspectFit
            starImageView.tintColor = .asset(.lightGrey)
            addArrangedSubview(starImageView)
        }

        updateStarViews()
    }

    private func updateStarViews() {
        guard let rating = rating else {
            return
        }

        let clampedRating = max(0, min(rating, 5))

        for (index, starImageView) in arrangedSubviews.enumerated() {
            starImageView.tintColor = index < clampedRating ? .asset(.yellow) : .asset(.lightGrey)
        }
    }
}
