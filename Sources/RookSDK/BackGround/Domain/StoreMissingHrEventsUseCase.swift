//
//  StoreMissingHrEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/03/24.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol StoreMissingHrEventsUseCaseProtocol {
  func execute() async throws -> Bool
}

final class StoreMissingHrEventsUseCase: StoreMissingHrEventsUseCaseProtocol {

  private let extractionEvent: RookExtractionEventManager
  private let missingUseCase: MissingEventsDaysUseCaseProtocol
  private let transmissionEvents: RookHrEventTransmissionManager

  init(extractionEvent: RookExtractionEventManager, missingUseCase: MissingEventsDaysUseCaseProtocol, transmissionEvents: RookHrEventTransmissionManager) {
    self.extractionEvent = extractionEvent
    self.missingUseCase = missingUseCase
    self.transmissionEvents = transmissionEvents
  }

  func execute() async throws -> Bool {
    if let bodyHRMissingDates: [Date] = try? await missingUseCase.execute(for: .bodyHr) {
      for date in bodyHRMissingDates {
        let events: [RookHeartRateEvent] = await getEvents(from: date)
        for event in events {
          _ = await storeEvent(event: event)
        }
      }
    }

    if let physicalHeartRateDate: [Date] = try? await missingUseCase.execute(for: .physicalHr) {
      for date in physicalHeartRateDate {
        let events: [RookHeartRateEvent] = await getPhysicalEvents(from: date)
        for event in events {
          _ = await storeEvent(event: event)
        }
      }
    }

    return true
  }

  private func getEvents(from date: Date) async -> [RookHeartRateEvent] {
    await withCheckedContinuation { continuation in
      self.extractionEvent.getBodyHeartRateEvents(date: date) { [weak self] result in
        switch result {
        case .success(let events):
          if let excludingDate: Date = self?.transmissionEvents.getLastBodyHREventTransmittedDate() {
            let filterEvents: [RookHeartRateEvent] = events.filter({
              $0.metadata.datetime > excludingDate
            })
            continuation.resume(returning: filterEvents)
          } else {
            continuation.resume(returning: events)
          }
        case .failure:
          continuation.resume(returning: [])
        }
      }
    }
  }

  private func getPhysicalEvents(from date: Date) async -> [RookHeartRateEvent] {
    await withCheckedContinuation { continuation in
      self.extractionEvent.getPhysicalHeartRateEvents(date: date) { [weak self] result in
        switch result {
        case .success(let events):
          if let excludingDate: Date = self?.transmissionEvents.getLastPhysicalHREventTransmittedDate() {
            let filterEvents: [RookHeartRateEvent] = events.filter({
              $0.metadata.datetime > excludingDate
            })
            continuation.resume(returning: filterEvents)
          } else {
            continuation.resume(returning: events)
          }
        case .failure:
          continuation.resume(returning: [])
        }
      }
    }
  }

  private func storeEvent(event: RookHeartRateEvent) async -> Bool {
    await withCheckedContinuation { continuation in
      if let data: Data = event.dataEvent {
        self.transmissionEvents.enqueueHrEvent(data) { result in
          switch result {
          case .success(let success):
            continuation.resume(returning: success)
          case .failure:
            continuation.resume(returning: false)
          }
        }
      } else {
        continuation.resume(returning: false)
      }
    }
  }
}
