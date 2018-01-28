//
//  FetchHistoricalTrades.swift
//  CryptoBot
//
//  Created by Austin Feight on 1/17/18.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON
import ReactiveKit

protocol QuandlNetworkRequest: NetworkRequest {
  var dataset: String { get }
}

extension QuandlNetworkRequest {
  var baseURL: String { return "https://www.quandl.com/api/v3/datasets" }
  var endpoint: String { return "\(dataset)/data.json?api_key=8-hfwwwNYFyAoSmhUhzU" }
}

protocol FetchHistoricalDataType: QuandlNetworkRequest {
  func fetch(dataset: String) -> Promise<[FetchHistoricalData.Response]>
}

final class FetchHistoricalData: FetchHistoricalDataType, QuandlNetworkRequest {
  typealias ReturnType = [Response]
  
  var dataset = ""
  
  static var processingRequest = Property(false)
  
  struct Response: Codable {
    var date: Date
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var volumeBTC: Double
    var volumeCurrency: Double
    var weightedPrice: Double
  }
}

// MARK: - Interface
extension FetchHistoricalData {
  func fetch(dataset: String) -> Promise<[Response]>
  {
    guard !FetchHistoricalData.processingRequest.value else {
      let readyForRequest = FetchHistoricalData.processingRequest.filter(isFalse)
      return wait(for: readyForRequest, withTimeout: 60)
        .asVoid()
        .then { self.fetch(dataset: dataset) }
    }
    
    FetchHistoricalData.processingRequest.value = true
    
    self.dataset = dataset
    
    return request
      .sjResponse()
      .then { json in
        return try! json["dataset_data"]["data"].arrayValue.map(Response.init(json:))
      }
      .always {
        FetchHistoricalData.processingRequest.value = false
      }
  }
}

// MARK: - Helpers
fileprivate extension FetchHistoricalData.Response {
  init(json: JSON) throws
  {
    let json = json.arrayValue
    guard let dateString = json[0].string,
          let date = DateFormatter(withDateFormat: "yyyy-MM-dd").date(from: dateString),
          let open = json[1].double,
          let high = json[2].double,
          let low = json[3].double,
          let close = json[4].double,
          let volumeBTC = json[5].double,
          let volumeCurrency = json[6].double,
          let weightedPrice = json[7].double
      else { throw JSONSerializationError.serialization }
    
    self.date = date
    self.open = open
    self.high = high
    self.low = low
    self.close = close
    self.volumeBTC = volumeBTC
    self.volumeCurrency = volumeCurrency
    self.weightedPrice = weightedPrice
  }
}

enum JSONSerializationError: Error {
  case serialization
}

extension DateFormatter {
  convenience init(withDateFormat dateFormat: String)
  {
    self.init()
    
    self.dateFormat = dateFormat
  }
}

func isTrue(_ value: Bool) -> Bool { return value }
func isFalse(_ value: Bool) -> Bool { return !value }
