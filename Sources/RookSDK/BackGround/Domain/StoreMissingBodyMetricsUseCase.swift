//
//  StoreMissingBodyMetricsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 20/03/24.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol StoreMissingBodyMetricsUseCaseProtocol {
  func execute() async throws -> Bool
}

final class StoreMissingBodyMetricsUseCase: StoreMissingBodyMetricsUseCaseProtocol {
  
  private let extractionEvent: RookExtractionEventManager
  private let missingUseCase: MissingEventsDaysUseCaseProtocol
  private let transmissionEvents: RookBodyMetricsEventTransmissionManager
  
  init(extractionEvent: RookExtractionEventManager,
       missingUseCase: MissingEventsDaysUseCaseProtocol,
       transmissionEvents: RookBodyMetricsEventTransmissionManager) {
    self.extractionEvent = extractionEvent
    self.missingUseCase = missingUseCase
    self.transmissionEvents = transmissionEvents
  }
  
  func execute() async throws -> Bool {
    let dates: [Date] = try await missingUseCase.execute(for: .bodyMetrics)
    let events: [RookBodyMetricsEvent] = try await self.getBatchEvents(with: dates)
    return try await storeBatchEvents(events: events)
  }
  
  private func getBatchEvents(with dates: [Date]) async throws -> [RookBodyMetricsEvent] {
    var events: [RookBodyMetricsEvent] = []
    for date in dates {
      guard let eventToAppend: [RookBodyMetricsEvent] = try? await getEvents(from: date) else {
        continue
      }
      events.append(contentsOf: eventToAppend)
    }
    if let excludingDate: Date = transmissionEvents.getLastBodyMetricsEventTransmittedDate()  {
      return events.filter({
        $0.metaData.datetime > excludingDate
      })
    }
    return events
  }

  private func getEvents(from date: Date) async throws -> [RookBodyMetricsEvent] {
    try await withCheckedThrowingContinuation { continuation in
      extractionEvent.getBodyMetricsEvents(date: date) { result in
        switch result {
        case .success(let events):
          continuation.resume(returning: events)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }

  private func storeBatchEvents(events: [RookBodyMetricsEvent]) async throws -> Bool {
    for event in events {
      _ = try? await self.storeEvent(event: event)
    }
    return true
  }

  private func storeEvent(event: RookBodyMetricsEvent) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      guard let dataEvent = event.dataEvent else {
        return continuation.resume(throwing: RookConnectErrors.emptyEvent)
      }
      self.transmissionEvents.enqueueBodyMetricsEvent(dataEvent) { result in
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
