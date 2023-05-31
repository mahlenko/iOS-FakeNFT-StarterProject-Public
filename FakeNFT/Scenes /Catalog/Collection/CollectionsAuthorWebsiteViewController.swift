import WebKit

final class CollectionsAuthorWebsiteViewController: UIViewController {
    var website: URL
    
    init(website: URL) {
        self.website = website
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let webview = WKWebView(frame: .zero)
        
        //TODO: вынести это в презентер, чтобы не ругалось на главный поток
            webview.load(URLRequest(url: website))
        //--------------
        
        webview.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webview)
        
        NSLayoutConstraint.activate([
            webview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

