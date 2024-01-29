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

  let backGroundManager: RookBackGroundExtraction = RookBackGroundExtraction.shared
  
  var handleRequestSummariesData: (() -> Void)?
  var handleRequestActivityEventsData: (() -> Void)?
  
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

  lazy var activityMissingEvents: UploadMissingActivityEventsProtocol = {
    return UploadMissingActivityEvents(
      extractionManager: self.extractionEventManager,
      useCases: UploadMissingActivityEvents.UseCases(
        missingDateUseCase: MissingEventsDaysUseCase(
          localDataSource: EventLocalDataSource(
            activityEventTransmissionManger: self.activityTransmissionManager
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
  }

  @objc public func enableBackGroundForSummaries() {
    handleRequestSummariesData?()
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
    let summariesUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask()
    pendingUseCase.execute { [weak self] _ in
      self?.handleSummariesUploaded?()
      UIApplication.shared.endBackgroundTask(summariesUploadTask)
    }
  }

  func initiateBackgroundTask() -> UIBackgroundTaskIdentifier {
    var identifier: UIBackgroundTaskIdentifier? = nil
    identifier = UIApplication.shared.beginBackgroundTask {
      UIApplication.shared.endBackgroundTask(identifier!)
    }
    return identifier!
  }

  private func storeMissing(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.missingUseCase.execute(upload: false)
        completion()
      } catch {
        completion()
      }
    }
  }
}
