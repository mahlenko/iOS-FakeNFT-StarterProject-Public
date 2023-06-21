import Foundation

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = self < 10000 ? 5 : 2
        return String(formatter.string(from: number) ?? "")
    }
}
