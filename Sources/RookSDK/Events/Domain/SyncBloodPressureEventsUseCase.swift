//
//  SyncBloodPressureEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 06/12/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol SyncBloodPressureEventsUseCaseProtocol {
  func execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class SyncBloodPressureEventsUseCase: SyncBloodPressureEventsUseCaseProtocol {
  
  // MARK:  Properties
  
  private let extractionManager: RookExtractionEventManager = RookExtractionEventManager()
  private let transmissionManger: RookBloodPressureEventTransmissionManager = RookBloodPressureEventTransmissionManager()
  
  // MARK:  Helpers
  
  func  execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    extractionManager.getBloodPressureEvents(date: date) { [weak self] result in
      switch result {
      case .success(let events):
        self?.handleEvents(events, completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  func handleEvents(_ events: [RookBloodPressureEvent], completion: @escaping (Result<Bool, Error>) -> Void) {
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    for event in events {
      guard let data: Data = event.eventData else {
        continue
      }
      dispatchGroup.enter()
      transmissionManger.enqueueBloodPressureEvent(data) { _ in
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
