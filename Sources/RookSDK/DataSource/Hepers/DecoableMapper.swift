//
//  EncodableMapper.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 23/04/24.
//

import Foundation

struct EncodableMapper {
  func asDictionary<T: Encodable>(object: T) throws -> [String: Any] {
    let data: Data = try JSONEncoder().encode(object)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}
