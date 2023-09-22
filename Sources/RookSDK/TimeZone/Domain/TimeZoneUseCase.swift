//
//  TimeZoneUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 20/09/23.
//

import Foundation

protocol TimeZoneUseCaseProtocol {
  func execute(completion: @escaping (Result<Bool, Error>) -> Void)
}

final class TimeZoneUseCase: TimeZoneUseCaseProtocol {
  
  // MARK:  Properties
  
  let dataManager: TimeZoneDataManagerProtocol
  
  // MARK:  Init
  
  init(dataManager: TimeZoneDataManagerProtocol = TimeZoneDataManager()) {
    self.dataManager = dataManager
  }
  
  // MARK:  Helpers
  
  func execute(completion: @escaping (Result<Bool, Error>) -> Void) {
    uploadTimeZone(completion: completion)
  }
  
  private func uploadTimeZone(completion: @escaping (Result<Bool, Error>) -> Void) {
    dataManager.getTimeZone() { [weak self] result in
      
      switch result {
      case .success(let data):
        self?.handleTimeZoneExtraction(timeZone: data, completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  private func handleTimeZoneExtraction(timeZone: UserTimeZoneDTO,
                                        completion: @escaping (Result<Bool, Error>) -> Void) {
    dataManager.uploadTimeZone(timezone: timeZone.timeZone,
                               offset: timeZone.offset,
                               completion: completion)
  }
  
}
