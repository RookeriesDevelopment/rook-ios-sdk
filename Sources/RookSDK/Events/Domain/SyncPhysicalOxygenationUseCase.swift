//
//  SyncPhysicalOxygenationUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol SyncPhysicalOxygenationUseCaseProtocol {
  func execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class SyncPhysicalOxygenationUseCase: SyncPhysicalOxygenationUseCaseProtocol {
  
  // MARK:  Properties
  
  private let extractionEvent: RookExtractionEventManager = RookExtractionEventManager()
  private let transmissionEvent: RookOxygenationEventTransmissionManager = RookOxygenationEventTransmissionManager()
  
  // MARK:  Init
  
  // MARK:  Helpers
  
  func execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    extractionEvent.getPhysicalOxygenationEvents(date: date) { [weak self] result in
      switch result {
      case .success(let events):
        self?.handleEvents(events, completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  func handleEvents(_ events: [RookOxygentationEvent], completion: @escaping (Result<Bool, Error>) -> Void) {
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    for event in events {
      guard let data: Data = event.dataEvent else {
        continue
      }
      dispatchGroup.enter()
      transmissionEvent.enqueueOxygenationEvent(data) { _ in
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      self.uploadEvents(completion: completion)
    }
  }
  
  func uploadEvents(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.transmissionEvent.uploadEvent(completion: completion)
  }
  
}
