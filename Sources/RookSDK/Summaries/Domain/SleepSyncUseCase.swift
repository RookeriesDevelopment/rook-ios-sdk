//
//  SleepSyncUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol SummarySyncUseCaseProtocol {
  func execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class SleepSyncUseCase: SummarySyncUseCaseProtocol {
  
  // MARK:  Properties
  
  private let summariesExtraction: RookExtractionManager = RookExtractionManager()
  
  private let sleepTransmissionManager: RookSleepTransmissionManager = RookSleepTransmissionManager()
  
  // MARK:  Init
  
  // MARK:  Helpers
  
  func execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    summariesExtraction.getSleepSummay(date: date) { [weak self] result in
      switch result {
      case .success(let summary):
        self?.handleSummary(summary, completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  private func handleSummary(_ summary: RookSleepData, completion: @escaping (Result<Bool, Error>) -> Void) {
    
    guard let data: Data = summary.getData() else {
      return completion(.failure(RookConnectErrors.emptySummary))
    }
    sleepTransmissionManager.enqueueSleepSummary(with: data) { [weak self] result in
      switch result {
      case .success(_):
        self?.uploadSamplesStored(completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  private func uploadSamplesStored(completion: @escaping (Result<Bool, Error>) -> Void) {
    sleepTransmissionManager.uploadSleepSummaries(completion: completion)
  }
  
  
}
