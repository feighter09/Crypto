//
//  Alamofire+Promise.swift
//  CryptoBot
//
//  Created by Austin Feight on 1/17/18.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

extension DataRequest {
  func defaultResponse() -> Promise<DefaultDataResponse>
  {
    let (promise, fulfill, _) = Promise<DefaultDataResponse>.pending()
    
    response(queue: nil, completionHandler: fulfill)
    
    return promise
  }
  
  func response<ResponseType: Codable>() -> Promise<ResponseType>
  {
    return defaultResponse().then(execute: handle(response:))
  }
  
  func sjResponse() -> Promise<JSON>
  {
    return defaultResponse()
      .then(execute: handleData(response:))
      .then { try JSON(data: $0) }
  }
  
  func handleData(response: DefaultDataResponse) throws -> Data
  {
    guard let httpResponse = response.response
      else { throw Errors.noResponse }
    NSLog("\(httpResponse.statusCode)")
    
    if let error = response.error { throw error }
    guard let data = response.data
      else { throw Errors.emptyResponse }
    
    switch httpResponse.statusCode {
    case 200...299:
      return data
    default:
      let parseJSONData = { (data: Data) in try? JSONSerialization.jsonObject(with: data, options: []) }
      let userInfo = response.data.flatMap(parseJSONData) as? [String : Any]
      throw HTTPError(status: httpResponse.statusCode, userInfo: userInfo ?? [:])
    }
  }
  
  func handle<ResponseType: Codable>(response: DefaultDataResponse) throws -> ResponseType
  {
    let data = try handleData(response: response)
    return try JSONDecoder().decode(ResponseType.self, from: data)
  }
  
  enum Errors: Error {
    case noResponse
    case emptyResponse
  }
  
  var httpSuccessCodes: CountableClosedRange<Int> { return 200...299 }
  var decoder: JSONDecoder { return JSONDecoder(dateDecodingStrategy: .millisecondsSince1970) }
}

struct HTTPError: Error {
  let status: Int
  let userInfo: [String : Any]
}

extension JSONDecoder {
  convenience init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate)
  {
    self.init()
    self.dateDecodingStrategy = dateDecodingStrategy
  }
}
