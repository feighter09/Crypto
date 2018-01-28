import Alamofire
import Foundation
import PromiseKit

let lastYear = Date(timeIntervalSinceNow: -1 * 30 * 24 * 60 * 60)
let exchanges = ["COINBASE", "BITSTAMP", "ITBIT", "KRAKEN"]
let datasets = exchanges.map { "BCHARTS/\($0)USD" }

let fetches = datasets.map(FetchHistoricalData().fetch)

when(fulfilled: fetches)
  .then { datas in
    NSLog("\(datas)")

    for (i, data) in datas.enumerated() {
      let prices = data.map { $0.close }.map { "\($0)" }.joined(separator: "\n")
      try! prices.write(toFile: "/Users/austin/Other/crypto/CryptoBot/daily_bitcoin_\(exchanges[i]).txt", atomically: true, encoding: .utf8)
    }
    
  }
  .always {
    RunLoop.current.run(until: Date())
  }

RunLoop.current.run()
