//
//  SyncYesterdaySummaryUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/12/23.
//

import Foundation

protocol SyncYesterdaySummaryUseCaseProtocol {
  func execute(completion: @escaping () -> Void)
}

final class SyncYesterdaySummaryUseCase: SyncYesterdaySummaryUseCaseProtocol {

  private let sleepSync: SleepSyncUseCase
  private let physicalSync: PhysicalSyncUseCase
  private let bodySync: BodySyncUseCase

  init(sleepSync: SleepSyncUseCase,
       physicalSync: PhysicalSyncUseCase,
       bodySync: BodySyncUseCase) {
    self.sleepSync =  sleepSync
    self.physicalSync =  physicalSync
    self.bodySync =  bodySync
  }
  
  func execute(completion: @escaping () -> Void) {
    let currentDate: Date = Date()
    guard let yesterdayDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
      return completion()
    }
    
    Task {
      
      do {
        _ = try await uploadAsyncSleepSummary(currentDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncPhysicalSummary(yesterdayDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncBodySummary(yesterdayDate)
      } catch {
      }
      
      completion()
    }
  }
  
}

// MARK:  Async Methods

extension SyncYesterdaySummaryUseCase {
  func uploadAsyncSleepSummary(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.sleepSync.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncPhysicalSummary(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.physicalSync.execute(date: date) { eventResult in
        switch eventResult {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
  
  func uploadAsyncBodySummary(_ date: Date) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.bodySync.execute(date: date) { eventResult in
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
