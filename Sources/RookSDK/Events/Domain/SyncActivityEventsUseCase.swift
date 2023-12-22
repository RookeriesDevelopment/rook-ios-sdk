//
//  SyncActivityEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol SyncActivityEventsUseCaseProtocol {
  func execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class SyncActivityEventsUseCase: SyncActivityEventsUseCaseProtocol {
  
  // MARK:  Properties
  
  private let extractionManager: RookExtractionEventManager = RookExtractionEventManager()
  private let transmissionManger: RookActivityEventTransmissionManager = RookActivityEventTransmissionManager()
  
  // MARK:  Helpers
  
  func  execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    extractionManager.getActivityEvents(date: date) { [weak self] result in
      switch result {
      case .success(let events):
        self?.handleEvents(events, completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  func handleEvents(_ events: [RookActivityEvent], completion: @escaping (Result<Bool, Error>) -> Void) {
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    for event in events {
      guard let data: Data = event.eventData else {
        continue
      }
      dispatchGroup.enter()
      transmissionManger.enqueActivityEvent(data) { _ in
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      self.uploadEvents(completion: completion)
    }
  }
  
  func uploadEvents(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.transmissionManger.uploadEvents(completion: completion)
  }
  
}
