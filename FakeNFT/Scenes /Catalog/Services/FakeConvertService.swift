import Foundation

final class FakeConvertService: CryptoConverterProtocol {
    var currenciesCount = 8
    
    func convertUSD(to coin: CryptoCoin, amount: Double) -> Double {
        switch coin {
        case .BTC:
            return 0.000036804135018 * amount
        case .APE:
            return 0.319488817891374 * amount
        case .ADA:
            return 2.631578947368421 * amount
        case .DOGE:
            return 13.793103448275862 * amount
        case .ETH:
            return 1.0 * amount
        case .SHIB:
            return 115740.740740740740741 * amount
        case .SOL:
            return 0.047348484848485 * amount
        case .USDT:
            return 1.0 * amount
        }
    }
    
    func getCryptocurrencies() -> [Cryptocurrency] {
        [
            Cryptocurrency(name: "Bitcoin", shortname: .BTC),
            Cryptocurrency(name: "ApeCoin", shortname: .APE),
            Cryptocurrency(name: "Cardano", shortname: .ADA),
            Cryptocurrency(name: "Dogecoin", shortname: .DOGE),
            Cryptocurrency(name: "Ethereum", shortname: .ETH),
            Cryptocurrency(name: "Shiba Inu", shortname: .SHIB),
            Cryptocurrency(name: "Solana", shortname: .SOL),
            Cryptocurrency(name: "Tether", shortname: .USDT)
        ]
    }
}
