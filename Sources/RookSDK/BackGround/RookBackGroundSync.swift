//
//  RookBackGroundSync.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 23/01/24.
//

import Foundation
import RookAppleHealth
import HealthKit
import RookConnectTransmission
import UIKit

@objc public class RookBackGroundSync: NSObject {

  @objc public static let shared: RookBackGroundSync = RookBackGroundSync()

  @objc public var handleSummariesUploaded: (() -> Void)?
  @objc public var handleActivityEventsUploaded: (() -> Void)?
  public var handleEventsUploaded: ((RookEventType) -> Void)?

  let backGroundManager: RookBackGroundExtraction = RookBackGroundExtraction.shared
  
  var handleRequestSummariesData: (() -> Void)?
  var handleRequestActivityEventsData: (() -> Void)?
  var handleRequestEventsData: (() -> Void)?
  
  
  let pendingUseCase: SyncPendingUseCaseProtocol = SyncPendingUseCase()
  private let extractionManger: RookExtractionEventManager = RookExtractionEventManager()
  
  let missingUseCase: UploadMissingSummariesProtocol
  let eventsUseCase: SyncYesterdayEventsUseCase.UseCases
  let activityMissingEvents: UploadMissingActivityEventsProtocol
  let activityTransmissionManager: RookActivityEventTransmissionManager
  
  private override init() {
    let extractionManager: RookExtractionManager = RookExtractionManager()
    let sleepTransmissionManager: RookSleepTransmissionManager = RookSleepTransmissionManager()
    let physicalTransmission: RookPhysicalTransmissionManager = RookPhysicalTransmissionManager()
    let bodyTranmission: RookBodyTransmissionManager = RookBodyTransmissionManager()
    let oxygenationTransmission: RookOxygenationEventTransmissionManager = RookOxygenationEventTransmissionManager()
    let heartRateTransmission: RookHrEventTransmissionManager = RookHrEventTransmissionManager()
    let bloodPressureTransmission: RookBloodPressureEventTransmissionManager = RookBloodPressureEventTransmissionManager()
    let bloodGlucoseTransmission: RookGlucoseEventTransmissionManager = RookGlucoseEventTransmissionManager()
    let temperatureTransmission: RookTemperatureEventTransmissionManager = RookTemperatureEventTransmissionManager()
    let bodyMetricsTransmission: RookBodyMetricsEventTransmissionManager = RookBodyMetricsEventTransmissionManager()
    let missingUseCases: UploadMissingSummariesProtocol = UploadMissingSummaries(
      useCases: UploadMissingSummaries.UseCases(
        missingDateUseCase: MissingDaysUseCase(
          localDataSource: SummaryLocalDataSource(
            sleepTransmissionManger: sleepTransmissionManager,
            physicalTransmissionManger: physicalTransmission,
            bodyTransmissionManger: bodyTranmission)),
        extractionSleepUseCase: ExtractionSleepUseCase(
          extractionManager: extractionManager,
          sleepTransmissionManger: sleepTransmissionManager),
        extractionPhysicalUseCase: ExtractionPhysicalUseCase(
          extractionManager: extractionManager,
          physicalTransmissionManager: physicalTransmission),
        extractionBodyUseCase: ExtractionBodyUseCase(
          extractionManager: extractionManager,
          bodyTransmissionManager: bodyTranmission),
        uploadPendingUseCases: SyncPendingUseCase()))
    let eventsMissing: MissingEventsDaysUseCaseProtocol = MissingEventsDaysUseCase(
      localDataSource: EventLocalDataSource(
        transmissionLocalDataSource: TransmissionLocalDataSource()))
    let activityTransmission: RookActivityEventTransmissionManager = RookActivityEventTransmissionManager()

    self.missingUseCase = missingUseCases
    self.activityTransmissionManager = activityTransmission
    
    self.activityMissingEvents = UploadMissingActivityEvents(
      extractionManager: extractionManger,
      useCases: UploadMissingActivityEvents.UseCases(
        missingDateUseCase: MissingEventsDaysUseCase(
          localDataSource: EventLocalDataSource(transmissionLocalDataSource: TransmissionLocalDataSource()))),
      transmissionActivityEvents: activityTransmission)

    self.eventsUseCase = SyncYesterdayEventsUseCase.UseCases(
      oxygenationStoreUseCase: StoreMissingOxygenationEventsUseCase(
        extractionEvent: extractionManger,
        missingUseCase: eventsMissing,
        transmissionEvents: oxygenationTransmission),
      oxygenationTransmission: oxygenationTransmission,
      heartRateStoreUseCase: StoreMissingHrEventsUseCase(
        extractionEvent: extractionManger,
        missingUseCase: eventsMissing,
        transmissionEvents: heartRateTransmission),
      heartRateTransmission: heartRateTransmission,
      activityUseCase: UploadMissingActivityEvents(
        extractionManager: extractionManger,
        useCases: UploadMissingActivityEvents.UseCases(missingDateUseCase: eventsMissing),
        transmissionActivityEvents: RookActivityEventTransmissionManager()),
      pressureStoreUseCase: StoreMissingBloodPressureUseCase(
        extractionEvent: extractionManger,
        missingUseCase: eventsMissing,
        transmissionEvents: bloodPressureTransmission),
      pressureTransmission: bloodPressureTransmission,
      glucoseStoreUseCase: StoreMissingBloodGlucoseUseCase(
        extractionEvent: extractionManger,
        missingUseCase: eventsMissing,
        transmissionEvents: bloodGlucoseTransmission),
      glucoseTransmission: bloodGlucoseTransmission,
      temperatureStoreUseCase: StoreMissingTemperatureEventsUseCase(
        extractionEvent: extractionManger,
        missingUseCase: eventsMissing,
        transmissionEvents: temperatureTransmission),
      temperatureTransmission: temperatureTransmission,
      bodyMetricsStoreUseCase: StoreMissingBodyMetricsUseCase(
        extractionEvent: extractionManger,
        missingUseCase: eventsMissing,
        transmissionEvents: bodyMetricsTransmission),
      bodyMetricsTransmission: bodyMetricsTransmission,
      lastExtractionUseCase: LastExtractionEventDateUseCase())
    super.init()
  }

  @objc public func setBackListeners() {
    backGroundManager.isBackgroundEnable(for: .allSummariesBackGroundExtractionEnable) { [weak self] (isEnable) in
      if isEnable {
        self?.setBackGround()
      } else {
        self?.handleRequestSummariesData = {
          self?.backGroundManager.setBackGroundEnable(for: .allSummariesBackGroundExtractionEnable)
          self?.setBackGround()
        }
      }
    }
    activityEventsBackListener()
    setBackGroundEventListeners()
  }

  @objc public func enableBackGroundForSummaries() {
    handleRequestSummariesData?()
    enableBackGroundForEvents()
  }

  @objc public func disableBackGroundForSummaries() {
    backGroundManager.setBackGroundDisable(for: .allSummariesBackGroundExtractionEnable)
  }

  private func setBackGround() {
    backGroundManager.setBackGroundListener(type: .heartRate) { [weak self] (completionUpdate, error) in
      self?.storeMissing {
        completionUpdate()
        self?.initUploadBackgroundTask()
      }
    }
  }

  private func initUploadBackgroundTask() {
    if let summariesUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask() {
      pendingUseCase.execute { [weak self] _ in
        self?.handleSummariesUploaded?()
        UIApplication.shared.endBackgroundTask(summariesUploadTask)
      }
    }

    if let heartUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask() {
      eventsUseCase.heartRateTransmission.uploadHrEvents() { [weak self] _ in
        self?.handleSummariesUploaded?()
        UIApplication.shared.endBackgroundTask(heartUploadTask)
      }
    }
  }

  func initiateBackgroundTask() -> UIBackgroundTaskIdentifier? {
    var identifier: UIBackgroundTaskIdentifier? = nil
    identifier = UIApplication.shared.beginBackgroundTask {
      if let identifier: UIBackgroundTaskIdentifier = identifier {
        UIApplication.shared.endBackgroundTask(identifier)
      }
    }
    return identifier
  }

  private func storeMissing(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.missingUseCase.execute(upload: false)
        _ = try await self.eventsUseCase.heartRateStoreUseCase.execute()
        completion()
      } catch {
        completion()
      }
    }
  }
}

// MARK:  HeartRate

extension RookBackGroundSync {

  private func storeHeartRate(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.eventsUseCase.heartRateStoreUseCase.execute()
      } catch { }
      completion()
    }
  }

  private func uploadHeartRateBackGroundTask() {
    if let eventUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask() {
      self.eventsUseCase.heartRateTransmission.uploadHrEvents() { [weak self] _ in
        self?.handleEventsUploaded?(.heartRate)
        UIApplication.shared.endBackgroundTask(eventUploadTask)
      }
    }
  }
}
