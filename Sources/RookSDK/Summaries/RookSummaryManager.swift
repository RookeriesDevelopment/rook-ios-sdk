//
//  RookSummaryManager.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation

@objc public final class RookSummaryManger: NSObject {
  
  // MARK:  Properties
  
  private let sleepUseCase: SummarySyncUseCaseProtocol = SleepSyncUseCase()
  private let physicalUseCase: SummarySyncUseCaseProtocol = PhysicalSyncUseCase()
  private let bodyUseCase: SummarySyncUseCaseProtocol = BodySyncUseCase()
  private let pendingUseCase: SyncPendingUseCaseProtocol = SyncPendingUseCase()
  // MARK:  Init
  
  @objc public override init() {
  }
  
  // MARK:  Helpers
  
  public func syncSleepSummary(from date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    sleepUseCase.execute(date: date, completion: completion)
  }
  
  public func syncPhysicalSummary(from date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    physicalUseCase.execute(date: date, completion: completion)
  }
  
  public func syncBodySummary(from date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    bodyUseCase.execute(date: date, completion: completion)
  }
  
  public func syncPendingSummaries(completion: @escaping (Result<Bool, Error>) -> Void) {
    pendingUseCase.execute(completion: completion)
  }
  
}
