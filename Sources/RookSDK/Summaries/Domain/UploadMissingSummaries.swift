//
//  UploadMissingSummaries.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/01/24.
//

import Foundation
import RookAppleHealth

protocol UploadMissingSummariesProtocol {
  func execute(upload: Bool) async throws -> Bool
}

final class UploadMissingSummaries: UploadMissingSummariesProtocol {

  struct UseCases {
    let missingDateUseCase: MissingDaysUseCaseProtocol
    let extractionSleepUseCase: ExtractionSleepUseCaseProtocol
    let extractionPhysicalUseCase: ExtractionPhysicalUseCaseProtocol
    let extractionBodyUseCase: ExtractionBodyUseCaseProtocol
    let uploadPendingUseCases: SyncPendingUseCaseProtocol
  }

  private let useCases: UseCases

  init(useCases: UseCases) {
    self.useCases = useCases
  }

  func execute(upload: Bool) async throws -> Bool {
    await self.storeMissingSleep()
    await self.storeMissingPhysical()
    await self.storeMissingBody()
    if upload {
      return try await self.uploadData()
    } else {
      return true
    }
  }

  private func storeMissingSleep() async {
    do {
      let dates: [Date] = try await useCases.missingDateUseCase.execute(for: .sleep)
      for date in dates {
        _ = try await useCases.extractionSleepUseCase.execute(date: date)
      }
    } catch { }
  }

  private func storeMissingPhysical() async {
    do {
      let dates: [Date] = try await useCases.missingDateUseCase.execute(for: .physical)
      for date in dates {
        _ = try await useCases.extractionPhysicalUseCase.execute(date: date)
      }
    } catch {
    }
  }
  
  private func storeMissingBody() async {
    do {
      let dates: [Date] = try await useCases.missingDateUseCase.execute(for: .body)
      for date in dates {
        _ = try await useCases.extractionBodyUseCase.execute(date: date)
      }
    } catch {
    }
  }

  private func uploadData() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      self.useCases.uploadPendingUseCases.execute { result in
        switch result {
        case .success(let success):
          continuation.resume(returning: success)
        case .failure(let failure):
          continuation.resume(throwing: failure)
        }
      }
    }
  }
}
