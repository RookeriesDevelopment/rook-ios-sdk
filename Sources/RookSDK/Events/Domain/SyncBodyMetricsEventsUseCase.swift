//
//  SyncBodyMetricsEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 26/02/24.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol SyncBodyMetricsEventsUseCaseProtocol {
  func execute(date: Date,
               excludingDatesBefore: Date?,
               completion: @escaping (Result<Bool, Error>) -> Void)
}

final class SyncBodyMetricsEventsUseCase: SyncBodyMetricsEventsUseCaseProtocol {
  
  // MARK:  Properties
  
  private let extractionEvent: RookExtractionEventManager
  private let transmissionEvent: RookBodyMetricsEventTransmissionManager
  
  // MARK:  Init
  
  init(extractionEvent: RookExtractionEventManager,
       transmissionEvent: RookBodyMetricsEventTransmissionManager) {
    self.extractionEvent = extractionEvent
    self.transmissionEvent = transmissionEvent
  }
  
  // MARK:  Helpers
  
  func execute(date: Date,
               excludingDatesBefore: Date?,
               completion: @escaping (Result<Bool, Error>) -> Void) {
    extractionEvent.getBodyMetricsEvents(date: date) { [weak self] result in
      switch result {
      case .success(let events):
        if let excludingDatesBefore: Date = excludingDatesBefore {
          let filterEvents: [RookBodyMetricsEvent] = events.filter { event in
            return event.metaData.datetime > excludingDatesBefore
          }
          self?.handleEvents(filterEvents, completion: completion)
        } else {
          self?.handleEvents(events, completion: completion)
        }
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  func handleEvents(_ events: [RookBodyMetricsEvent], completion: @escaping (Result<Bool, Error>) -> Void) {
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    for event in events {
      guard let data: Data = event.dataEvent else {
        continue
      }
      dispatchGroup.enter()
      transmissionEvent.enqueueBodyMetricsEvent(data) { _ in
        dispatchGroup.leave()
      }
    }
    
    dispatchGroup.notify(queue: .main) {
      self.uploadEvents(completion: completion)
    }
  }
  
  func uploadEvents(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.transmissionEvent.uploadEvents(completion: completion)
  }
  
}

