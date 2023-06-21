import UIKit

final class StylizedLabel: UILabel {
    var style: LabelStyles?
    
    init(style: LabelStyles) {
        super.init(frame: .zero)
        self.style = style
        translatesAutoresizingMaskIntoConstraints = false
        
        switch style {
        case .nftCollectionNameInNFTCollectionList:
            font = UIFont.nftCollectionNameInNFTCollectionList
        case .nftName:
            font = UIFont.nftCollectionName
        case .priceLabel:
            font = UIFont.nftAuthor
        case .priceInNFTCell:
            font = UIFont.priceInNFTCell
        }
        
        textColor = .asset(.black)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class LineHeightedLabel: UILabel {
    var withFont: UIFont
    var lineHeight: Double
    var linesCount: Int?
    var color: UIColor?
    var enabledUserInteraction: Bool? = false
    var string: String? = " "
    
    init(lineHeight: Double, withFont: UIFont, color: UIColor? = UIColor.black, linesCount: Int? = 1, enabledUserInteraction: Bool? = false, string: String? = " ") {
        self.lineHeight = lineHeight
        self.withFont = withFont
        self.color = color
        self.linesCount = linesCount
        self.enabledUserInteraction = enabledUserInteraction
        self.string = string
        
        super.init(frame: .infinite)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight
        let attrString = NSMutableAttributedString(string: string ?? " ")
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSAttributedString.Key.font, value: withFont, range: NSMakeRange(0, attrString.length))
        attributedText = attrString
        
        numberOfLines = 0
        textColor = color
        isUserInteractionEnabled = enabledUserInteraction ?? false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
