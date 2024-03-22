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

  private lazy var extractionManger: RookExtractionEventManager = {
    RookExtractionEventManager()
  }()

  private lazy var bodyTransmissionManager: RookBodyMetricsEventTransmissionManager = {
    RookBodyMetricsEventTransmissionManager()
  }()

  private lazy var syncBodyMetricsUseCase: SyncBodyMetricsEventsUseCaseProtocol = {
    return SyncBodyMetricsEventsUseCase(
      extractionEvent: extractionManger,
      transmissionEvent: bodyTransmissionManager)
  }()

  private lazy var missingDaysUseCase: MissingEventsDaysUseCaseProtocol = {
    MissingEventsDaysUseCase(
      localDataSource: EventLocalDataSource(
        transmissionLocalDataSource: TransmissionLocalDataSource()
      )
    )
  }()

  private lazy var oxygenationTransmission: RookOxygenationEventTransmissionManager = {
    RookOxygenationEventTransmissionManager()
  }()

  private lazy var heartRateTransmission: RookHrEventTransmissionManager = {
    RookHrEventTransmissionManager()
  }()

  private lazy var bloodPressureTransmission: RookBloodPressureEventTransmissionManager = {
    RookBloodPressureEventTransmissionManager()
  }()

  private lazy var bloodGlucoseTransmission: RookGlucoseEventTransmissionManager = {
    RookGlucoseEventTransmissionManager()
  }()

  private lazy var  temperatureTransmission: RookTemperatureEventTransmissionManager = {
    RookTemperatureEventTransmissionManager()
  }()

  private lazy var syncEventsUseCase: SyncYesterdayEventsUseCase = {
    let transmission: RookActivityEventTransmissionManager = RookActivityEventTransmissionManager()
    return SyncYesterdayEventsUseCase(
      useCases: SyncYesterdayEventsUseCase.UseCases(
        oxygenationStoreUseCase: StoreMissingOxygenationEventsUseCase(
          extractionEvent: extractionManger,
          missingUseCase: missingDaysUseCase,
          transmissionEvents: oxygenationTransmission),
        oxygenationTransmission: oxygenationTransmission,
        heartRateStoreUseCase: StoreMissingHrEventsUseCase(
          extractionEvent: extractionManger,
          missingUseCase: missingDaysUseCase,
          transmissionEvents: heartRateTransmission),
        heartRateTransmission: heartRateTransmission,
        activityUseCase: UploadMissingActivityEvents(
          extractionManager: extractionManger,
          useCases: UploadMissingActivityEvents.UseCases(
            missingDateUseCase: missingDaysUseCase),
          transmissionActivityEvents: RookActivityEventTransmissionManager()),
        pressureStoreUseCase: StoreMissingBloodPressureUseCase(
          extractionEvent: extractionManger,
          missingUseCase: missingDaysUseCase,
          transmissionEvents: bloodPressureTransmission),
        pressureTransmission: bloodPressureTransmission,
        glucoseStoreUseCase: StoreMissingBloodGlucoseUseCase(
          extractionEvent: extractionManger,
          missingUseCase: missingDaysUseCase,
          transmissionEvents: bloodGlucoseTransmission),
        glucoseTransmission: bloodGlucoseTransmission,
        temperatureStoreUseCase: StoreMissingTemperatureEventsUseCase(
          extractionEvent: extractionManger,
          missingUseCase: missingDaysUseCase,
          transmissionEvents: temperatureTransmission),
        temperatureTransmission: temperatureTransmission,
        bodyMetricsStoreUseCase: StoreMissingBodyMetricsUseCase(
          extractionEvent: extractionManger,
          missingUseCase: missingDaysUseCase,
          transmissionEvents: bodyTransmissionManager),
        bodyMetricsTransmission: bodyTransmissionManager,
        lastExtractionUseCase: LastExtractionEventDateUseCase()))
  }()
  
  // MARK:  Int
  
  @objc public override init() {
  }
  
  // MARK:  Helpers

  @objc public func syncEvents(completion: @escaping () -> Void) {
    self.syncEventsUseCase.execute(completion: completion)
  }

  @available(*, deprecated, renamed: "syncEvents")
  @objc public func syncYesterdayEvents(completion: @escaping () -> Void) {
    self.syncEventsUseCase.execute(completion: completion)
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

  public func syncBodyMetricsEvents(date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    syncBodyMetricsUseCase.execute(date: date, excludingDatesBefore: nil, completion: completion)
  }
  
  public func syncPendingEvents(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.syncPendingEventUseCase.execute(completion: completion)
  }
}
