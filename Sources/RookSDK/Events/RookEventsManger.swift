//
//  RookEventsManger.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation

public final class RookEventsManager {
  
  // MARK:  Properties
  
  private let syncBodyHrEventsUseCase: SyncBodyHeartRateEventsUseCaseProtocol = SyncBodyHeartRateEventsUseCase()
  private let syncPhysicalEventsUseCase: SyncPhysicalHeartRateEventsUseCaseProtocol = SyncPhysicalHeartRateEventsUseCase()
  
  private let syncBodyOxygenationEventsUseCase: SyncBodyOxygenationUseCaseProtocol = SyncBodyOxygenationUseCase()
  private let syncPhysicalOxygenationEventUseCase: SyncPhysicalOxygenationUseCaseProtocol = SyncPhysicalOxygenationUseCase()
  
  private let syncActivityEventsUseCase: SyncActivityEventsUseCaseProtocol = SyncActivityEventsUseCase()
  
  // MARK:  Int
  
  public init() {
  }
  
  // MARK:  Helpers
  
  public func syncBodyHeartRateEvent(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncBodyHrEventsUseCase.execute(date: date, completion: completion)
  }
  
  public func syncPhysicalHeartRateEvent(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncPhysicalEventsUseCase.execute(date: date, completion: completion)
  }
  
  public func syncBodyOxygenationEvent(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncBodyOxygenationEventsUseCase.execute(date: date, completion: completion)
  }
  
  public func syncPhysicalOxygenationEvent(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncPhysicalOxygenationEventUseCase.execute(date: date, completion: completion)
  }
  
  public func syncTrainingEvent(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncActivityEventsUseCase.execute(date: date, completion: completion)
  }
  
}
