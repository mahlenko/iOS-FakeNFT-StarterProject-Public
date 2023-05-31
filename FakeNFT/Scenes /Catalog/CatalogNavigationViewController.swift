import UIKit

final class CatalogNavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        pushViewController(CatalogViewController(), animated: false)
    }
}
