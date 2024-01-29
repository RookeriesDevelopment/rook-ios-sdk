//
//  ExtractionBodyUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/01/24.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol ExtractionBodyUseCaseProtocol {
  func execute(date: Date) async throws -> Bool
}

final class ExtractionBodyUseCase: ExtractionBodyUseCaseProtocol {
  
  private let extractionManager: RookExtractionManager
  private let bodyTransmissionManager: RookBodyTransmissionManager
  
  init(extractionManager: RookExtractionManager, bodyTransmissionManager: RookBodyTransmissionManager) {
    self.extractionManager = extractionManager
    self.bodyTransmissionManager = bodyTransmissionManager
  }
  
  func execute(date: Date) async throws -> Bool {
    return try await getSummary(date: date)
  }
  
  private func getSummary(date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      extractionManager.getBodySummary(date: date) { result in
        switch result {
        case .success(let data):
          self.storeSummary(summary: data) { result in
            switch result {
            case .success(let success):
              continuation.resume(returning: success)
            case .failure(let failure):
              continuation.resume(throwing: failure)
            }
          }
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  private func storeSummary(summary: RookBodyData,
                            completion: @escaping (Result<Bool, Error>) -> Void){
    guard let data: Data = summary.getData() else {
      return completion(.failure(RookConnectErrors.emptySummary))
    }
    bodyTransmissionManager.enqueueBodySummary(with: data, completion: completion)
  }
}
