import UIKit

enum LabelStyles: String {
    case NFTCollectionNameInNFTCollectionList
}

final class CustomLabel: UILabel {
    var style: LabelStyles?
    
    init(style: LabelStyles) {
        super.init(frame: .zero)
        self.style = style
        translatesAutoresizingMaskIntoConstraints = false
        switch style {
        case .NFTCollectionNameInNFTCollectionList:
            font = CustomFont.font(name: .SFProTextBold, size: 17)
            textColor = UIColor.NFTBlack
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String{
    var encodeUrl : String
    {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
    }
    var decodeUrl : String
    {
        return self.removingPercentEncoding!
    }
}
