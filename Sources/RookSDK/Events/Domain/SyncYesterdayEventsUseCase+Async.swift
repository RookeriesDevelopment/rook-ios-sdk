//
//  SyncYesterdayEventsUseCase+Async.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 21/12/23.
//

import Foundation

extension SyncYesterdayEventsUseCase {
  
  func uploadAsyncPhysicalOxygenation(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.useCases.physicalOxygenationUseCase.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncBodyOxygenation(_ date: Date,
                                  excludingDatesBefore: Date?) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.useCases.bodyOxygenationUseCase.execute(date: date, excludingDatesBefore: excludingDatesBefore) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncBodyHeartRate(_ date: Date, excludingDatesBefore: Date?) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.useCases.bodyHeartRateUseCase.execute(date: date,
                                        excludingDatesBefore: excludingDatesBefore) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncPhysicalHeartRate(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.useCases.physicalHeartRateUseCase.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncBloodPressure(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.useCases.pressureUseCase.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncBloodGlucose(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.useCases.glucoseUseCase.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncTemperature(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.useCases.temperatureUseCase.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }

  func uploadAsyncBodyMetrics(_ date: Date, excluding: Date?) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.useCases.syncBodyMetricsUseCase.execute(date: date, excludingDatesBefore: excluding) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
}
