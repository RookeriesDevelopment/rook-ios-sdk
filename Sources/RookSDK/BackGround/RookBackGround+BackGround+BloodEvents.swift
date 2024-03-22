//
//  RookBackGround+BackGround+BloodEvents.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 21/03/24.
//

import Foundation
import UIKit

// MARK:  Blood Pressure

extension RookBackGroundSync {
  func setBloodPressureObserverQuery() {
    backGroundManager.setBackGroundListener(type: .bloodPressureSystolic) { [weak self] (completionUpdate, error) in
      self?.storeBloodPressure {
        completionUpdate()
        self?.uploadBloodPressureBackGroundTask()
      }
    }
  }

  private func storeBloodPressure(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.eventsUseCase.pressureStoreUseCase.execute()
      } catch { }
      completion()
    }
  }

  private func uploadBloodPressureBackGroundTask() {
    if let eventUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask() {
      self.eventsUseCase.pressureTransmission.uploadEvents() { [weak self] _ in
        self?.handleEventsUploaded?(.bloodPressure)
        UIApplication.shared.endBackgroundTask(eventUploadTask)
      }
    }
  }
}

// MARK:  Blood Glucose

extension RookBackGroundSync {
  func setBloodGlucoseObserverQuery() {
    backGroundManager.setBackGroundListener(type: .bloodGlucose) { [weak self] (completionUpdate, error) in
      self?.storeBloodGlucose {
        completionUpdate()
        self?.uploadBloodGlucoseBackGroundTask()
      }
    }
  }

  private func storeBloodGlucose(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.eventsUseCase.glucoseStoreUseCase.execute()
      } catch { }
      completion()
    }
  }

  private func uploadBloodGlucoseBackGroundTask() {
    if let eventUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask() {
      self.eventsUseCase.glucoseTransmission.uploadEvents() { [weak self] _ in
        self?.handleEventsUploaded?(.bloodGlucose)
        UIApplication.shared.endBackgroundTask(eventUploadTask)
      }
    }
  }
}
