//
//  RookSummaryManager.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/08/23.
//

import Foundation

public final class RookSummaryManger {
  
  // MARK:  Properties
  
  private let sleepUseCase: SummarySyncUseCaseProtocol = SleepSyncUseCase()
  private let physicalUseCase: SummarySyncUseCaseProtocol = PhysicalSyncUseCase()
  private let bodyUseCase: SummarySyncUseCaseProtocol = BodySyncUseCase()
  
  // MARK:  Init
  
  public init() {
  }
  
  // MARK:  Helpers
  
  public func syncSleepSummary(form date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    sleepUseCase.execute(date: date, completion: completion)
  }
  
  public func syncPhysicalSummary(form date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    physicalUseCase.execute(date: date, completion: completion)
  }
  
  public func syncBodySummary(from date: Date, completion: @escaping (Result<Bool, Error>) -> Void) {
    bodyUseCase.execute(date: date, completion: completion)
  }
  
}
