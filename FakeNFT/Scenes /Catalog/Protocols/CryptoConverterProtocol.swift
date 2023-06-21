import Foundation

protocol CryptoConverterProtocol {
    func convertUSD(to: CryptoCoin, amount: Double) -> Double
    func getCryptocurrencies() -> [Cryptocurrency]
}
