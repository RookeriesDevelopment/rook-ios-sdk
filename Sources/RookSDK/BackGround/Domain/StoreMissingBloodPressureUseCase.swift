//
//  StoreMissingBloodPressureUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 20/03/24.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol StoreMissingBloodPressureUseCaseProtocol {
  func execute() async throws -> Bool
}

final class StoreMissingBloodPressureUseCase: StoreMissingBloodPressureUseCaseProtocol {
  
  private let extractionEvent: RookExtractionEventManager
  private let missingUseCase: MissingEventsDaysUseCaseProtocol
  private let transmissionEvents: RookBloodPressureEventTransmissionManager
  
  init(extractionEvent: RookExtractionEventManager,
       missingUseCase: MissingEventsDaysUseCaseProtocol,
       transmissionEvents: RookBloodPressureEventTransmissionManager) {
    self.extractionEvent = extractionEvent
    self.missingUseCase = missingUseCase
    self.transmissionEvents = transmissionEvents
  }
  
  func execute() async throws -> Bool {
    let dates: [Date] = try await missingUseCase.execute(for: .bloodPressure)
    let events: [RookBloodPressureEvent] = try await self.getBatchEvents(with: dates)
    return try await storeBatchEvents(events: events)
  }
  
  private func getBatchEvents(with dates: [Date]) async throws -> [RookBloodPressureEvent] {
    var events: [RookBloodPressureEvent] = []
    for date in dates {
      guard let eventToAppend: [RookBloodPressureEvent] = try? await getEvents(from: date) else {
        continue
      }
      events.append(contentsOf: eventToAppend)
    }
    if let excludingDate: Date = transmissionEvents.getLastBloodPressureEventTransmittedDate()  {
      return events.filter({
        $0.metadata.datetime > excludingDate
      })
    }
    return events
  }

  private func getEvents(from date: Date) async throws -> [RookBloodPressureEvent] {
    try await withCheckedThrowingContinuation { continuation in
      extractionEvent.getBloodPressureEvents(date: date) { result in
        switch result {
        case .success(let events):
          continuation.resume(returning: events)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }

  private func storeBatchEvents(events: [RookBloodPressureEvent]) async throws -> Bool {
    for event in events {
      _ = try? await self.storeEvent(event: event)
    }
    return true
  }

  private func storeEvent(event: RookBloodPressureEvent) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      guard let dataEvent = event.eventData else {
        return continuation.resume(throwing: RookConnectErrors.emptyEvent)
      }
      self.transmissionEvents.enqueueBloodPressureEvent(dataEvent) { result in
        switch result {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
}
