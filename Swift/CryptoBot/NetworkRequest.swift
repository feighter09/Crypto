//
//  NetworkRequest.swift
//  CryptoBot
//
//  Created by Austin Feight on 1/21/18.
//

import Alamofire
import Foundation
import PromiseKit

protocol NetworkRequest {
  associatedtype ReturnType: Codable
  
  var url: String { get }
  var baseURL: String { get }
  var endpoint: String { get }
  var method: HTTPMethod { get }
  var params: [String : Any]? { get }
  var encoding: ParameterEncoding { get }
  var headers: [String : String]? { get }
}

extension NetworkRequest {
  var url: String { return "\(baseURL)/\(endpoint)" }
  
  var method: HTTPMethod { return .get }
  var params: [String : Any]? { return nil }
  var encoding: ParameterEncoding { return URLEncoding.default }
  var headers: [String : String]? { return nil }
  
  func performRequest() -> Promise<ReturnType> { return request.response() }
  
  var request: DataRequest {
    return Alamofire.request(url, method: method, parameters: params, encoding: encoding, headers: headers)
  }
}
