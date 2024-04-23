//
//  RookSummaryManager.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

@objc public final class RookSummaryManager: NSObject {
  
  // MARK:  Properties
  
  private let sleepUseCase: SummarySyncUseCaseProtocol = SleepSyncUseCase()
  private let physicalUseCase: SummarySyncUseCaseProtocol = PhysicalSyncUseCase()
  private let bodyUseCase: SummarySyncUseCaseProtocol = BodySyncUseCase()
  
  
  private lazy var pendingUseCase: SyncPendingUseCaseProtocol = {
    return SyncPendingUseCase()
  }()
  
  private lazy var yesterdayUseCase: SyncYesterdaySummaryUseCaseProtocol = {
    let extractionManager: RookExtractionManager = RookExtractionManager()
    let sleepTransmissionManager: RookSleepTransmissionManager = RookSleepTransmissionManager()
    let physicalTransmissionManager: RookPhysicalTransmissionManager = RookPhysicalTransmissionManager()
    let bodyTransmission: RookBodyTransmissionManager = RookBodyTransmissionManager()
    return SyncYesterdaySummaryUseCase(
      uploadMissingSummaries: UploadMissingSummaries(
      useCases: UploadMissingSummaries.UseCases(
        missingDateUseCase: MissingDaysUseCase(
          localDataSource: SummaryLocalDataSource(
            sleepTransmissionManger: sleepTransmissionManager,
            physicalTransmissionManger: physicalTransmissionManager,
            bodyTransmissionManger: bodyTransmission)),
        extractionSleepUseCase: ExtractionSleepUseCase(
          extractionManager: extractionManager,
          sleepTransmissionManger: sleepTransmissionManager),
        extractionPhysicalUseCase: ExtractionPhysicalUseCase(
          extractionManager: extractionManager,
          physicalTransmissionManager: physicalTransmissionManager),
        extractionBodyUseCase: ExtractionBodyUseCase(
          extractionManager: extractionManager,
          bodyTransmissionManager: bodyTransmission),
        uploadPendingUseCases: self.pendingUseCase)
      ))
  }()
  // MARK:  Init
  
  @objc public override init() {
  }
  
  // MARK:  Helpers

  @objc public func syncSummaries(completion: @escaping () -> Void) {
    yesterdayUseCase.execute(completion: completion)
  }

  @available(*, deprecated, renamed: "syncSummaries")
  @objc public func syncYesterdaySummaries(completion: @escaping () -> Void) {
    yesterdayUseCase.execute(completion: completion)
  }
  
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
