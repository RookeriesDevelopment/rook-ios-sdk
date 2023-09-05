//
//  SyncPendingUseCase.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 28/08/23.
//

import Foundation
import RookConnectTransmission

protocol SyncPendingUseCaseProtocol {
  func execute(completion: @escaping (Result<Bool, Error>) -> Void)
}

final class SyncPendingUseCase: SyncPendingUseCaseProtocol {
  
  // MARK:  Properties
  
  private let bodyTransmissionManager: RookBodyTransmissionManager = RookBodyTransmissionManager()
  private let physicalTransmissionManager: RookPhysicalTransmissionManager = RookPhysicalTransmissionManager()
  private let sleepTransmissionManager: RookSleepTransmissionManager = RookSleepTransmissionManager()
  
  // MARK:  Helpers
  
  func execute(completion: @escaping (Result<Bool, Error>) -> Void) {
    uploadPending(completion: completion)
  }
  
  private func uploadPending(completion: @escaping (Result<Bool, Error>) -> Void) {
    
    let dispatchGroup: DispatchGroup = DispatchGroup()
    var results: [String: Result<Bool, Error>] = [:]
    
    dispatchGroup.enter()
    bodyTransmissionManager.uploadBodySummaries() { result in
      results.updateValue(result, forKey: "body")
      dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    physicalTransmissionManager.uploadPhysicalSummaries() { result in
      results.updateValue(result, forKey: "physical")
      dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    sleepTransmissionManager.uploadSleepSummaries() { result in
      results.updateValue(result, forKey: "sleep")
      dispatchGroup.leave()
    }
    
    dispatchGroup.notify(queue: .main) {
      self.handleResuls(results, completion: completion)
    }
  }
  
  private func handleResuls(_ results: [String: Result<Bool, Error>],
                            completion: @escaping (Result<Bool, Error>) -> Void) {
    guard !results.isEmpty else {
      return completion(.failure(RookConnectErrors.nothingToUpdate))
    }
    
    for result in results {
      if let value: Bool = try? result.value.get(), value {
        return completion(.success(true))
      }
    }
    
    completion(.success(false))
  }
  
}
