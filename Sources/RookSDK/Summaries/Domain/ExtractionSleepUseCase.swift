//
//  ExtractionSleepUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/01/24.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol ExtractionSleepUseCaseProtocol {
  func execute(date: Date) async throws -> Bool
}

final class ExtractionSleepUseCase: ExtractionSleepUseCaseProtocol {

  private let extractionManager: RookExtractionManager
  private let sleepTransmissionManger: RookSleepTransmissionManager

  init(extractionManager: RookExtractionManager,
       sleepTransmissionManger: RookSleepTransmissionManager) {
    self.extractionManager = extractionManager
    self.sleepTransmissionManger = sleepTransmissionManger
  }

  func execute(date: Date) async throws -> Bool {
    return try await getSummary(date: date)
  }

  private func getSummary(date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      extractionManager.getSleepSummary(date: date) { [weak self] result in
        switch result {
        case .success(let data):
          self?.storeBatchSummaries(data) { result in
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

  private func storeBatchSummaries(_ summaries: [RookSleepData], completion: @escaping (Result<Bool, Error>) -> Void) {
    Task {
      var storeError: Error?
      var result: Bool = true
      for summary in summaries {
        do {
          result = try await storeSummary(summary: summary)
        } catch {
          storeError = error
        }
      }
      
      if let storeError: Error = storeError {
        completion(.failure(storeError))
      } else {
        completion(.success(result))
      }
    }
  }

  private func storeSummary(summary: RookSleepData) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      guard let data: Data = summary.getData() else {
        return continuation.resume(throwing: RookConnectErrors.emptySummary)
      }
      self.sleepTransmissionManger.enqueueSleepSummary(with: data) { result in
        switch result {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
}
