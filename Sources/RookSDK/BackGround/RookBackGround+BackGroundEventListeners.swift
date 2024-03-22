//
//  RookBackGround+BackGroundEventListeners.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/03/24.
//

import Foundation
import RookAppleHealth
import UIKit

extension RookBackGroundSync {
  
  func setBackGroundEventListeners() {
    setOxygenationObserverQuery()
    setTemperatureObserverQuery()
    setBloodPressureObserverQuery()
    setBloodGlucoseObserverQuery()
    setBodyMetricsObserverQuery()
  }
}

// MARK:  Oxygenation

extension RookBackGroundSync {
  func setOxygenationObserverQuery() {
    backGroundManager.setBackGroundListener(type: .oxygenSaturation) { [weak self] (completionUpdate, error) in
      self?.storeOxygenation {
        completionUpdate()
        self?.uploadOxygenationBackGroundTask()
      }
    }
  }

  private func storeOxygenation(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.eventsUseCase.oxygenationStoreUseCase.execute()
      } catch { }
      completion()
    }
  }

  private func uploadOxygenationBackGroundTask() {
    if let eventUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask() {
      self.eventsUseCase.oxygenationTransmission.uploadEvent() { [weak self] _ in
        self?.handleEventsUploaded?(.oxygenation)
        UIApplication.shared.endBackgroundTask(eventUploadTask)
      }
    }
  }
}

// MARK:  Temperature

extension RookBackGroundSync {
  func setTemperatureObserverQuery() {
    backGroundManager.setBackGroundListener(type: .bodyTemperature) { [weak self] (completionUpdate, error) in
      self?.storeTemperature {
        completionUpdate()
        self?.uploadTemperatureBackGroundTask()
      }
    }
  }

  private func storeTemperature(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.eventsUseCase.temperatureStoreUseCase.execute()
      } catch { }
      completion()
    }
  }

  private func uploadTemperatureBackGroundTask() {
    if let eventUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask() {
      self.eventsUseCase.temperatureTransmission.uploadEvents() { [weak self] _ in
        self?.handleEventsUploaded?(.temperature)
        UIApplication.shared.endBackgroundTask(eventUploadTask)
      }
    }
  }
}
