//
//  UploadMissingActivityEvents.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 24/01/24.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

protocol UploadMissingActivityEventsProtocol {
  func execute(upload: Bool) async throws -> Bool
}


final class UploadMissingActivityEvents: UploadMissingActivityEventsProtocol {
  
  struct UseCases {
    let missingDateUseCase: MissingEventsDaysUseCaseProtocol
  }
  
  private let extractionManager: RookExtractionEventManager
  private let useCases: UseCases
  private let transmissionActivityEvents: RookActivityEventTransmissionManager
  
  init(extractionManager: RookExtractionEventManager, useCases: UseCases, transmissionActivityEvents: RookActivityEventTransmissionManager) {
    self.extractionManager = extractionManager
    self.useCases = useCases
    self.transmissionActivityEvents = transmissionActivityEvents
  }
  
  func execute(upload: Bool) async throws -> Bool {
    await self.storeActivityEvents()
    if upload {
      return try await self.transmissionActivityEvents.uploadEventsAsync()
    } else {
      return true
    }
  }

  private func storeActivityEvents() async {
    do {
      let dates: [Date] = try await useCases.missingDateUseCase.execute(for: .activityEvent)
      for date in dates {
        await self.storeEvents(from: date)
      }
    } catch { }
  }

  private func storeEvents(from date: Date) async {
    let eventFromDate: [RookActivityEvent] = await getEvents(
      from: date,
      excluding: transmissionActivityEvents.getLastActivityEventTransmittedDate())
    for event in eventFromDate {
      _ = await storeActivity(event: event)
    }
  }

  private func getEvents(from date: Date, excluding: Date?) async -> [RookActivityEvent] {
    await withCheckedContinuation { continuation in
      self.extractionManager.getActivityEvents(
        date: date,
        excludingDatesBefore: excluding) { result in
          switch result {
          case .success(let events):
            continuation.resume(returning: events)
          case .failure:
            continuation.resume(returning: [])
          }
        }
    }
  }

  private func storeActivity(event: RookActivityEvent) async -> Bool {
    await withCheckedContinuation { continuation in
      if let data: Data = event.eventData {
        self.transmissionActivityEvents.enqueActivityEvent(data) { result in
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
