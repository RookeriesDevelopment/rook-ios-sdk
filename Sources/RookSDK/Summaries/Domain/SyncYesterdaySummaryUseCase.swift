//
//  SyncYesterdaySummaryUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/12/23.
//

import Foundation

protocol SyncYesterdaySummaryUseCaseProtocol {
  func execute(completion: @escaping () -> Void)
}

final class SyncYesterdaySummaryUseCase: SyncYesterdaySummaryUseCaseProtocol {

  private let uploadMissingSummaries: UploadMissingSummariesProtocol
  
  init(uploadMissingSummaries: UploadMissingSummariesProtocol) {
    self.uploadMissingSummaries = uploadMissingSummaries
  }
  
  func execute(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.uploadMissingSummaries.execute(upload: true)
        completion()
      } catch {
        completion()
      }
      
    }
  }
  
}
