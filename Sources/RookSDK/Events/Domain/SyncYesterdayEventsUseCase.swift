//
//  SyncYesterdayEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/12/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

final class SyncYesterdayEventsUseCase {
  
  struct UseCases {
    let oxygenationStoreUseCase: StoreMissingOxygenationEventsUseCaseProtocol
    let oxygenationTransmission: RookOxygenationEventTransmissionManager
    let heartRateStoreUseCase: StoreMissingHrEventsUseCaseProtocol
    let heartRateTransmission: RookHrEventTransmissionManager
    let activityUseCase: UploadMissingActivityEventsProtocol
    let pressureStoreUseCase: StoreMissingBloodPressureUseCaseProtocol
    let pressureTransmission: RookBloodPressureEventTransmissionManager
    let glucoseStoreUseCase: StoreMissingBloodGlucoseUseCaseProtocol
    let glucoseTransmission: RookGlucoseEventTransmissionManager
    let temperatureStoreUseCase: StoreMissingTemperatureEventsUseCaseProtocol
    let temperatureTransmission: RookTemperatureEventTransmissionManager
    let bodyMetricsStoreUseCase: StoreMissingBodyMetricsUseCaseProtocol
    let bodyMetricsTransmission: RookBodyMetricsEventTransmissionManager
    let lastExtractionUseCase: LastExtractionEventDateUseCase
  }

  let useCases: UseCases
  
  init(useCases: UseCases) {
    self.useCases = useCases
  }
  
  func execute(completion: @escaping () -> Void) {
    Task {
      await uploadCommonEvents()
      await uploadBodyRelatedEvents()
      await uploadBloodEvents()
      completion()
    }
  }

  private func uploadCommonEvents() async {
    do {
      _ = try await self.useCases.activityUseCase.execute(upload: true)
    } catch { }

    do {
      _ = try await useCases.oxygenationStoreUseCase.execute()
      _ = try await useCases.oxygenationTransmission.uploadEventsAsync()
    } catch { }

    do {
      _ = try await useCases.heartRateStoreUseCase.execute()
      _ = try await useCases.heartRateTransmission.uploadHrEventsAsync()
    } catch { }
  }

  private func uploadBloodEvents() async {
    do {
      _ = try await useCases.pressureStoreUseCase.execute()
      _ = try await useCases.pressureTransmission.uploadEventsAsync()
    } catch { }

    do {
      _ = try await useCases.glucoseStoreUseCase.execute()
      _ = try await useCases.glucoseTransmission.uploadEventsAsync()
    } catch { }
  }

  private func uploadBodyRelatedEvents() async {
    do {
      _ = try await useCases.temperatureStoreUseCase.execute()
      _ = try await useCases.temperatureTransmission.uploadEventsAsync()
    } catch { }

    do {
      _ = try await useCases.bodyMetricsStoreUseCase.execute()
      _ = try await useCases.bodyMetricsTransmission.uploadEventsAsync()
    } catch { }
  }
}
