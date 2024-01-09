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
    
    Task {
      var errors: [String: Error] = [:]
      
      do {
        let _ = try await bodyTransmissionManager.uploadBodySummariesAsync()
      } catch {
        errors.updateValue(error, forKey: "body")
      }
      
      do {
        let _ = try await physicalTransmissionManager.uploadPhysicalSummariesAsync()
      } catch {
        errors.updateValue(error, forKey: "physical")
      }
      
      do {
        let _ = try await sleepTransmissionManager.uploadSleepSummariesAsync()
      } catch {
        errors.updateValue(error, forKey: "sleep")
      }
      
      self.handleResults(errors, completion: completion)
    }
  }
  
  private func handleResults(_ errors: [String: Error],
                            completion: @escaping (Result<Bool, Error>) -> Void) {
    
    guard let error: Error = errors.first?.value else {
      return completion(.success(true))
    }
    completion(.failure(error))
  }
  
}
