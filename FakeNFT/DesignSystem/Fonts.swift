import UIKit

extension UIFont {
    // Ниже приведены примеры шрифтов, настоящие шрифты надо взять из фигмы

    // Headline Fonts
    static var headline1 = UIFont.systemFont(ofSize: 34, weight: .bold)
    static var headline2 = UIFont.systemFont(ofSize: 28, weight: .bold)
    static var headline3 = UIFont.systemFont(ofSize: 22, weight: .bold)
    static var headline4 = UIFont.systemFont(ofSize: 20, weight: .bold)

    // Body Fonts
    static var bodyRegular = UIFont.systemFont(ofSize: 17, weight: .regular)
    static var bodyBold = UIFont.systemFont(ofSize: 17, weight: .bold)

    // Caption Fonts
    static var caption1 = UIFont.systemFont(ofSize: 15, weight: .regular)
    static var caption2 = UIFont.systemFont(ofSize: 13, weight: .regular)
}

enum FontNames: String {
    case SFProDisplaySemibold
    case SFProTextMedium
    case SFProTextRegular
    case SFProTextBold
    case SFProDisplayBold
    case SFProDisplayRegular
}

final class CustomFont: UIFont {
    static func font(name: FontNames, size: CGFloat) -> UIFont {
        let defaultFont = UIFont.systemFont(ofSize: size)
        switch name {
        case .SFProDisplaySemibold:
            return UIFont(name: "SFProDisplay-Semibold", size: size) ?? defaultFont
        case .SFProTextMedium:
            return UIFont(name: "SFProText-Medium", size: size) ?? defaultFont
        case .SFProTextRegular:
            return UIFont(name: "SFProText-Regular", size: size) ?? defaultFont
        case .SFProTextBold:
            return UIFont(name: "SFProText-Bold", size: size) ?? defaultFont
        case .SFProDisplayBold:
            return UIFont(name: "SFProDisplay-Bold", size: size) ?? defaultFont
        case .SFProDisplayRegular:
            return UIFont(name: "SFProDisplay-Regular", size: size) ?? defaultFont
        }
    }
}
