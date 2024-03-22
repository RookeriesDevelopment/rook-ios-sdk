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
  
  lazy var pendingUseCase: SyncPendingUseCaseProtocol = {
    return SyncPendingUseCase()
  }()
  
  lazy var extractionManager: RookExtractionManager = {
    RookExtractionManager()
  }()

  lazy var extractionEventManager: RookExtractionEventManager =  {
    RookExtractionEventManager()
  }()

  lazy var activityTransmissionManager: RookActivityEventTransmissionManager = { RookActivityEventTransmissionManager()
  }()
  
  lazy var missingUseCase: UploadMissingSummariesProtocol = {
    let sleepTransmissionManager: RookSleepTransmissionManager = RookSleepTransmissionManager()
    let physicalTransmissionManager: RookPhysicalTransmissionManager = RookPhysicalTransmissionManager()
    let bodyTransmission: RookBodyTransmissionManager = RookBodyTransmissionManager()
    return UploadMissingSummaries(
      useCases: UploadMissingSummaries.UseCases(
        missingDateUseCase: MissingDaysUseCase(
          localDataSource: SummaryLocalDataSource(
            sleepTransmissionManger: sleepTransmissionManager,
            physicalTransmissionManger: physicalTransmissionManager,
            bodyTransmissionManger: bodyTransmission)),
        extractionSleepUseCase: ExtractionSleepUseCase(
          extractionManager: self.extractionManager,
          sleepTransmissionManger: sleepTransmissionManager),
        extractionPhysicalUseCase: ExtractionPhysicalUseCase(
          extractionManager: self.extractionManager,
          physicalTransmissionManager: physicalTransmissionManager),
        extractionBodyUseCase: ExtractionBodyUseCase(
          extractionManager: self.extractionManager,
          bodyTransmissionManager: bodyTransmission),
        uploadPendingUseCases: self.pendingUseCase)
      )
  }()

  private lazy var extractionManger: RookExtractionEventManager = {
    RookExtractionEventManager()
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

  private lazy var bodyTransmissionManager: RookBodyMetricsEventTransmissionManager = {
    RookBodyMetricsEventTransmissionManager()
  }()

  lazy var eventsUseCase: SyncYesterdayEventsUseCase.UseCases = {
    return SyncYesterdayEventsUseCase.UseCases(
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
        lastExtractionUseCase: LastExtractionEventDateUseCase())
  }()

  lazy var activityMissingEvents: UploadMissingActivityEventsProtocol = {
    return UploadMissingActivityEvents(
      extractionManager: self.extractionEventManager,
      useCases: UploadMissingActivityEvents.UseCases(
        missingDateUseCase: MissingEventsDaysUseCase(
          localDataSource: EventLocalDataSource(
            transmissionLocalDataSource: TransmissionLocalDataSource()
          )
        )
      ),
      transmissionActivityEvents: self.activityTransmissionManager)
  }()

  
  private override init() { }

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
