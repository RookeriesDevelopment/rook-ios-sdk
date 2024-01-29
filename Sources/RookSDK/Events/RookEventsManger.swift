//
//  RookEventsManger.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

@objc public final class RookEventsManager: NSObject {
  
  // MARK:  Properties
  
  private lazy var syncBodyHrEventsUseCase: SyncBodyHeartRateEventsUseCase = {
    SyncBodyHeartRateEventsUseCase()
  }()

  private lazy var syncPhysicalEventsUseCase: SyncPhysicalHeartRateEventsUseCase = { SyncPhysicalHeartRateEventsUseCase()
  }()
  
  private lazy var syncBodyOxygenationEventsUseCase: SyncBodyOxygenationUseCase = { 
    SyncBodyOxygenationUseCase()
  }()

  private lazy var syncPhysicalOxygenationEventUseCase: SyncPhysicalOxygenationUseCase = { SyncPhysicalOxygenationUseCase()
  }()

  private lazy var syncActivityEventsUseCase: SyncActivityEventsUseCase = {
    SyncActivityEventsUseCase()
  }()
  
  private lazy var syncTemperatureUseCase: SyncTemperatureEventsUseCase = {
    SyncTemperatureEventsUseCase()
  }()
  
  private lazy var syncBloodGlucoseUseCase: SyncBloodGlucoseEventsUseCase = {
    SyncBloodGlucoseEventsUseCase()
  }()
  
  private lazy var syncBloodPressureUseCase: SyncBloodPressureEventsUseCase = {
    SyncBloodPressureEventsUseCase()
  }()
  
  private lazy var syncPendingEventUseCase: SyncPendingEventsUseCase = {
    SyncPendingEventsUseCase()
  }()
  
  private lazy var syncYesterdayEventsUseCase: SyncYesterdayEventsUseCase = {
    let transmission: RookActivityEventTransmissionManager = RookActivityEventTransmissionManager()
    return SyncYesterdayEventsUseCase(
      useCases: SyncYesterdayEventsUseCase.UseCases(
        physicalOxygenationUseCase: syncPhysicalOxygenationEventUseCase,
        bodyOxygenationUseCase: syncBodyOxygenationEventsUseCase,
        physicalHeartRateUseCase: syncPhysicalEventsUseCase,
        activityUseCase: UploadMissingActivityEvents(
          extractionManager: RookExtractionEventManager(),
          useCases: UploadMissingActivityEvents.UseCases(
            missingDateUseCase: MissingEventsDaysUseCase(
              localDataSource: EventLocalDataSource(
                activityEventTransmissionManger: transmission)
            )
          ),
          transmissionActivityEvents: transmission),
        bodyHeartRateUseCase: syncBodyHrEventsUseCase,
        pressureUseCase: syncBloodPressureUseCase,
        glucoseUseCase: syncBloodGlucoseUseCase,
        temperatureUseCase: syncTemperatureUseCase,
        lastExtractionUseCase: LastExtractionEventDateUseCase()
      )
    )
  }()
  
  // MARK:  Int
  
  @objc public override init() {
  }
  
  // MARK:  Helpers
  
  @objc public func syncYesterdayEvents(completion: @escaping () -> Void) {
    self.syncYesterdayEventsUseCase.execute(completion: completion)
  }
  
  public func syncBodyHeartRateEvent(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncBodyHrEventsUseCase.execute(date: date, excludingDatesBefore: nil, completion: completion)
  }
  
  public func syncPhysicalHeartRateEvent(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncPhysicalEventsUseCase.execute(date: date, completion: completion)
  }
  
  public func syncBodyOxygenationEvent(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncBodyOxygenationEventsUseCase.execute(date: date, excludingDatesBefore: nil, completion: completion)
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
