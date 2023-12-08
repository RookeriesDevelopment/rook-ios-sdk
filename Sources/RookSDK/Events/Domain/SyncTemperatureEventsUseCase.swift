//
//  SyncTemperatureEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 06/12/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol SyncTemperatureEventsUseCaseProtocol {
  func execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void)
}

final class SyncTemperatureEventsUseCase: SyncTemperatureEventsUseCaseProtocol {
  
  // MARK:  Properties
  
  private let extractionManager: RookExtractionEventManager = RookExtractionEventManager()
  private let transmissionManger: RookTemperatureEventTransmissionManager = RookTemperatureEventTransmissionManager()
  
  // MARK:  Helpers
  
  func  execute(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    extractionManager.getTemperatureEvents(date: date) { [weak self] result in
      switch result {
      case .success(let events):
        self?.handleEvents(events, completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  func handleEvents(_ events: [RookTemperatureEvent], completion: @escaping (Result<Bool, Error>) -> Void) {
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    for event in events {
      guard let data: Data = event.dataEvent else {
        continue
      }
      dispatchGroup.enter()
      transmissionManger.enqueueTemperatureEvent(data) { _ in
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
