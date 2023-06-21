//
//  UIViewController+Extensions.swift
//  FakeNFT
//

import UIKit

extension UIViewController {
    
    func hideKeyboardByTap() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
