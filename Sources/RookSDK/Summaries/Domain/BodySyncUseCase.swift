//
//  BodySyncUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

final class BodySyncUseCase: SummarySyncUseCaseProtocol {
  
  // MARK:  Properties
  
  private let summariesExtraction: RookExtractionManager = RookExtractionManager()
  
  private let transmissionManager: RookBodyTransmissionManager = RookBodyTransmissionManager()
  
  // MARK:  Init
  
  // MARK:  Helpers
  
  func execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    summariesExtraction.getBodySummary(date: date) { [weak self] result in
      switch result {
      case .success(let summary):
        self?.handleSummary(summary, completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  private func handleSummary(_ summary: RookBodyData, completion: @escaping (Result<Bool, Error>) -> Void) {
    
    guard let data: Data = summary.getData() else {
      return completion(.failure(RookConnectErrors.emptySummary))
    }
    transmissionManager.enqueueBodySummary(with: data) { [weak self] result in
      switch result {
      case .success(_):
        self?.uploadSamplesStored(completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  private func uploadSamplesStored(completion: @escaping (Result<Bool, Error>) -> Void) {
    transmissionManager.uploadBodySummaries(completion: completion)
  }
  
  
}
