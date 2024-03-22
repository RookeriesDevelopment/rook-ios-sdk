//
//  StoreMissingOxygenationEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/03/24.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol StoreMissingOxygenationEventsUseCaseProtocol {
  func execute() async throws -> Bool
}

final class StoreMissingOxygenationEventsUseCase: StoreMissingOxygenationEventsUseCaseProtocol {

  private let extractionEvent: RookExtractionEventManager
  private let missingUseCase: MissingEventsDaysUseCaseProtocol
  private let transmissionEvents: RookOxygenationEventTransmissionManager

  init(extractionEvent: RookExtractionEventManager, missingUseCase: MissingEventsDaysUseCaseProtocol, transmissionEvents: RookOxygenationEventTransmissionManager) {
    self.extractionEvent = extractionEvent
    self.missingUseCase = missingUseCase
    self.transmissionEvents = transmissionEvents
  }

  func execute() async throws -> Bool {
    await storeBodyEvents()
    await storePhysicalEvents()
    return true
  }

  private func storeBodyEvents() async {
    let dates: [Date] = await getDatesEvents(isBody: true)
    let events: [RookOxygentationEvent] = await getEvents(dates, fromBody: true)
    for event in events {
      _ = await self.storeEvent(event)
    }
  }

  private func storePhysicalEvents() async {
    let dates: [Date] = await getDatesEvents(isBody: false)
    let events: [RookOxygentationEvent] = await getEvents(dates, fromBody: false)
    for event in events {
      _ = await self.storeEvent(event)
    }
  }

  private func getDatesEvents(isBody: Bool) async -> [Date] {
    let dates: [Date]? =  try? await missingUseCase.execute(
      for: isBody ? .bodyOxygenation : .physicalOxygenation)
    return dates ?? []
  }

  private func getEvents(_ dates: [Date], fromBody: Bool) async -> [RookOxygentationEvent] {
    var events: [RookOxygentationEvent] = []
    for date in dates {
      if fromBody {
        let eventToAppend: [RookOxygentationEvent] = await getEvents(from: date)
        events.append(contentsOf: eventToAppend)
      } else {
        let eventToAppend: [RookOxygentationEvent] = await getPhysicalEvents(from: date)
        events.append(contentsOf: eventToAppend)
      }
    }
    if let excludingDate: Date = getLastDate(fromBody: fromBody) {
      let eventsFiltered: [RookOxygentationEvent] = events.filter({
        $0.metadata.datetime > excludingDate
      })
      return eventsFiltered
    }
    return events
  }

  private func getLastDate(fromBody: Bool) -> Date? {
    if fromBody {
      return transmissionEvents.getLastBodyOxygenationEventTransmittedDate()
    } else {
      return transmissionEvents.getLastPhysicalOxygenationEventTransmittedDate()
    }
  }

  private func getEvents(from date: Date) async -> [RookOxygentationEvent] {
    await withCheckedContinuation { continuation in
      self.extractionEvent.getBodyOxygenationEvents(date: date) { result in
        switch result {
        case .success(let events):
          continuation.resume(returning: events)
        case .failure:
          continuation.resume(returning: [])
        }
      }
    }
  }

  private func getPhysicalEvents(from date: Date) async -> [RookOxygentationEvent] {
    await withCheckedContinuation { continuation in
      self.extractionEvent.getPhysicalOxygenationEvents(date: date) { result in
        switch result {
        case .success(let events):
          continuation.resume(returning: events)
        case .failure:
          continuation.resume(returning: [])
        }
      }
    }
  }

  private func storeEvent(_ event: RookOxygentationEvent) async -> Bool {
    await withCheckedContinuation { continuation in
      guard let dataEvent = event.dataEvent else {
        return continuation.resume(returning: false)
      }

      transmissionEvents.enqueueOxygenationEvent(dataEvent) { result in
        switch result {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure:
          continuation.resume(returning: false)
        }
      }
    }
  }
}
