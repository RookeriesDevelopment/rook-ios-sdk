//
//  StoreMissingTemperatureEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 20/03/24.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol StoreMissingTemperatureEventsUseCaseProtocol {
  func execute() async throws -> Bool
}

final class StoreMissingTemperatureEventsUseCase: StoreMissingTemperatureEventsUseCaseProtocol {
  
  private let extractionEvent: RookExtractionEventManager
  private let missingUseCase: MissingEventsDaysUseCaseProtocol
  private let transmissionEvents: RookTemperatureEventTransmissionManager
  
  init(extractionEvent: RookExtractionEventManager,
       missingUseCase: MissingEventsDaysUseCaseProtocol,
       transmissionEvents: RookTemperatureEventTransmissionManager) {
    self.extractionEvent = extractionEvent
    self.missingUseCase = missingUseCase
    self.transmissionEvents = transmissionEvents
  }
  
  func execute() async throws -> Bool {
    let dates: [Date] = try await missingUseCase.execute(for: .temperature)
    let events: [RookTemperatureEvent] = try await self.getBatchEvents(with: dates)
    return try await storeBatchEvents(events: events)
  }
  
  private func getBatchEvents(with dates: [Date]) async throws -> [RookTemperatureEvent] {
    var events: [RookTemperatureEvent] = []
    for date in dates {
      guard let eventToAppend: [RookTemperatureEvent] = try? await getEvents(from: date) else {
        continue
      }
      events.append(contentsOf: eventToAppend)
    }
    if let excludingDate: Date = transmissionEvents.getLastTemperatureEventTransmittedDate()  {
      return events.filter({
        $0.metadata.datetime > excludingDate
      })
    }
    return events
  }

  private func getEvents(from date: Date) async throws -> [RookTemperatureEvent] {
    try await withCheckedThrowingContinuation { continuation in
      extractionEvent.getTemperatureEvents(date: date) { result in
        switch result {
        case .success(let events):
          continuation.resume(returning: events)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }

  private func storeBatchEvents(events: [RookTemperatureEvent]) async throws -> Bool {
    for event in events {
      _ = try? await self.storeEvent(event: event)
    }
    return true
  }

  private func storeEvent(event: RookTemperatureEvent) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      guard let dataEvent = event.dataEvent else {
        return continuation.resume(throwing: RookConnectErrors.emptyEvent)
      }
      self.transmissionEvents.enqueueTemperatureEvent(dataEvent) { result in
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