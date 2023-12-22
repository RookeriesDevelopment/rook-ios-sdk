//
//  RookEventsManger.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation

@objc public final class RookEventsManager: NSObject {
  
  // MARK:  Properties
  
  private let syncBodyHrEventsUseCase: SyncBodyHeartRateEventsUseCaseProtocol = SyncBodyHeartRateEventsUseCase()
  private let syncPhysicalEventsUseCase: SyncPhysicalHeartRateEventsUseCaseProtocol = SyncPhysicalHeartRateEventsUseCase()
  
  private let syncBodyOxygenationEventsUseCase: SyncBodyOxygenationUseCaseProtocol = SyncBodyOxygenationUseCase()
  private let syncPhysicalOxygenationEventUseCase: SyncPhysicalOxygenationUseCaseProtocol = SyncPhysicalOxygenationUseCase()
  
  private let syncActivityEventsUseCase: SyncActivityEventsUseCaseProtocol = SyncActivityEventsUseCase()
  
  private let syncTemperatureUseCase: SyncTemperatureEventsUseCaseProtocol = SyncTemperatureEventsUseCase()
  
  private let syncBloodGlucoseUseCase: SyncBloodGlucoseEventsUseCaseProtocol = SyncBloodGlucoseEventsUseCase()
  
  private let syncBloodPressureUseCase: SyncBloodPressureEventsUseCaseProtocol = SyncBloodPressureEventsUseCase()
  
  private let syncYesterdayEventsUseCase: SyncYesterdayEventsUseCase = SyncYesterdayEventsUseCase()
  
  private let syncPendingEventUseCase: SyncPendingEventsUseCaseProtocol = SyncPendingEventsUseCase()
  
  // MARK:  Int
  
  @objc public override init() {
  }
  
  // MARK:  Helpers
  
  @objc public func syncYesterdayEvents(completion: @escaping () -> Void) {
    syncYesterdayEventsUseCase.execute(completion: completion)
  }
  
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
  
  public func syncTemperatureEvents(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncTemperatureUseCase.execute(date: date, completion: completion)
  }
  
  public func syncBloodPressureEvents(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncBloodPressureUseCase.execute(date: date, completion: completion)
  }
  
  public func syncBloodGlucoseEvents(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncBloodGlucoseUseCase.execute(date: date, completion: completion)
  }
  
  public func syncPendingEvents(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.syncPendingEventUseCase.execute(completion: completion)
  }
}
