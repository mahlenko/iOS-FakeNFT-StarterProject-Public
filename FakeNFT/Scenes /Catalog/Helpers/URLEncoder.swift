import Foundation

class URLEncoder {
    var url: String
    
    var encodedURL: URL? {
        guard let encodedString = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed),
              let url = URL(string: encodedString)
        else { return nil }
        return url
    }
    
    init(url: String) {
        self.url = url
    }
}
