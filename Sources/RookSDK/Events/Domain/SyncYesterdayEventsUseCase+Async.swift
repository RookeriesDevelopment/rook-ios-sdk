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
      self.physicalOxygenationUseCase.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncBodyOxygenation(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.bodyOxygenationUseCase.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncBodyHeartRate(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.bodyHeartRateUseCase.execute(date: date) { eventResult in
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
      self.physicalHeartRateUseCase.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncActivity(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.activityUseCase.execute(date: date) { eventResult in
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
      self.pressureUseCase.execute(date: date) { eventResult in
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
      self.glucoseUseCase.execute(date: date) { eventResult in
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
      self.temperatureUseCase.execute(date: date) { eventResult in
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
