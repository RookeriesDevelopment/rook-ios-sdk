//
//  SynPendingEventsUseCase.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 28/08/23.
//

import Foundation
import RookConnectTransmission

protocol SynPendingEventsUseCaseProtocol {
  func execute(completion: @escaping (Result<Bool, Error>) -> Void)
}

final class SynPendingEventsUseCase: SynPendingEventsUseCaseProtocol {
  
  // MARK:  Properties
  
  private let transmissionHrEvent: RookHrEventTransmissionManager = RookHrEventTransmissionManager()
  private let transmissionOxygenationEvent: RookOxygenationEventTransmissionManager = RookOxygenationEventTransmissionManager()
  private let transmissionActivityManger: RookActivityEventTransmissionManager = RookActivityEventTransmissionManager()
  
  // MARK:  Helpers
  
  func execute(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.uploadEvents(completion: completion)
  }

  private func uploadEvents(completion: @escaping (Result<Bool, Error>) -> Void) {
    let dispatchGroup: DispatchGroup = DispatchGroup()
    var results: [String: Result<Bool, Error>] = [:]
    
    dispatchGroup.enter()
    transmissionHrEvent.uploadHrEvents() { result in
      results.updateValue(result, forKey: "hrEvents")
      dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    transmissionOxygenationEvent.uploadEvent() { result in
      results.updateValue(result, forKey: "oxygenationEvents")
      dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    transmissionActivityManger.uploadEvents() { result in
      results.updateValue(result, forKey: "activityEvents")
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
