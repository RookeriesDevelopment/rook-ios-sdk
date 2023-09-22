//
//  TimeZoneDataManager.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 20/09/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission


protocol TimeZoneDataManagerProtocol {
  func getTimeZone(completion: @escaping (Result<UserTimeZoneDTO, Error>) -> Void)
  func uploadTimeZone(timezone: String, offset: Int, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class TimeZoneDataManager: TimeZoneDataManagerProtocol {
  
  // MARK:  Propeties
  
  private let timeZoneExtraction: RookExtractionManager = RookExtractionManager()
  private let timeZoneTransmission: RookTimeZoneManager = RookTimeZoneManager()
  
  // MARK:  Helpers
  
  func getTimeZone(completion: @escaping (Result<UserTimeZoneDTO, Error>) -> Void) {
    self.timeZoneExtraction.getUserTimeZone() { result in
      switch result {
      case .success(let timeZone):
        completion(.success(TimeZoneMapper.mapTimeZone(timeZone)))
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  func uploadTimeZone(timezone: String, offset: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
    self.timeZoneTransmission.uploadUserTimeZone(timezone: timezone, offset: offset, completion: completion)
  }
  
}
