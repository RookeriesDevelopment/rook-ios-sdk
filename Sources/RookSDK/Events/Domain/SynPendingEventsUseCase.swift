//
//  SynPendingEventsUseCase.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 28/08/23.
//

import Foundation
import RookConnectTransmission

protocol SyncPendingEventsUseCaseProtocol {
  func execute(completion: @escaping (Result<Bool, Error>) -> Void)
}

final class SyncPendingEventsUseCase: SyncPendingEventsUseCaseProtocol {
  
  // MARK:  Properties
  
  private let transmissionHrEvent: RookHrEventTransmissionManager = RookHrEventTransmissionManager()
  private let transmissionOxygenationEvent: RookOxygenationEventTransmissionManager = RookOxygenationEventTransmissionManager()
  private let transmissionActivityManger: RookActivityEventTransmissionManager = RookActivityEventTransmissionManager()
  
  // MARK:  Helpers
  
  func execute(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.uploadEvents(completion: completion)
  }

  private func uploadEvents(completion: @escaping (Result<Bool, Error>) -> Void) {
    
    Task {
      var errors: [String: Error] = [:]
      
      //Hr
      do {
        _ = try await transmissionHrEvent.uploadHrEventsAsync()
      } catch {
        errors.updateValue(error, forKey: "hrEvents")
      }
      //Oxygenation
      do {
        _ = try await transmissionOxygenationEvent.uploadEventsAsync()
      } catch {
        errors.updateValue(error, forKey: "oxygenationEvents")
      }
      // Activity
      do {
        _ = try await transmissionActivityManger.uploadEventsAsync()
      } catch {
        errors.updateValue(error, forKey: "activityEvents")
      }
      
      handleResults(errors, completion: completion)
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
