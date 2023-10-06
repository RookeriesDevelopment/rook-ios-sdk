//
//  PhysicalSyncUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

final class PhysicalSyncUseCase: SummarySyncUseCaseProtocol {
  
  // MARK:  Properties
  
  private let summariesExtraction: RookExtractionManager = RookExtractionManager()
  
  private let transmissionManager: RookPhysicalTransmissionManager = RookPhysicalTransmissionManager()
  
  // MARK:  Init
  
  // MARK:  Helpers
  
  func execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    summariesExtraction.getPhysicalSummary(date: date) { [weak self] result in
      switch result {
      case .success(let summary):
        self?.handleSummary(summary, completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  private func handleSummary(_ summary: RookPhysicalData, completion: @escaping (Result<Bool, Error>) -> Void) {
    
    guard let data: Data = summary.getData() else {
      return completion(.failure(RookConnectErrors.emptySummary))
    }
    transmissionManager.enqueuePhysicalSummary(with: data) { [weak self] result in
      switch result {
      case .success(_):
        self?.uploadSamplesStored(completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  private func uploadSamplesStored(completion: @escaping (Result<Bool, Error>) -> Void) {
    transmissionManager.uploadPhysicalSummaries(completion: completion)
  }
  
  
}
