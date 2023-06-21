//
//  RatingStringMaker.swift
//  FakeNFT
//

import UIKit

protocol RatingStringMaker {
    func makeRatingString(from rating: Int) -> NSAttributedString
}

extension RatingStringMaker {
    func makeRatingString(from rating: Int) -> NSAttributedString {
        let fullString = NSMutableAttributedString(string: "")
        for count in 1...5 {
            let imageAttachment = NSTextAttachment()
            imageAttachment.bounds = CGRect(origin: .zero, size: CGSize(width: 14, height: 13))
            if count <= rating && rating != 0 {
                imageAttachment.image = UIImage(systemName: "star.fill")?.withTintColor(.asset(.yellow))
                fullString.append(NSAttributedString(attachment: imageAttachment))
            } else {
                imageAttachment.image = UIImage(systemName: "star.fill")?.withTintColor(.asset(.lightGray))
                fullString.append(NSAttributedString(attachment: imageAttachment))
            }
        }
        return fullString
    }
}
