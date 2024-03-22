//
//  RookBackGround+BodyMetricsEvents.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 21/03/24.
//

import Foundation
import UIKit

// MARK:  Blood Pressure

extension RookBackGroundSync {
  func setBodyMetricsObserverQuery() {
    backGroundManager.setBackGroundListener(type: .bodyMass) { [weak self] (completionUpdate, error) in
      self?.storeBodyMetrics {
        completionUpdate()
        self?.uploadBodyMetricsBackGroundTask()
      }
    }

    backGroundManager.setBackGroundListener(type: .height) { [weak self] (completionUpdate, error) in
      self?.storeBodyMetrics {
        completionUpdate()
        self?.uploadBodyMetricsBackGroundTask()
      }
    }

    backGroundManager.setBackGroundListener(type: .bodyMassIndex) { [weak self] (completionUpdate, error) in
      self?.storeBodyMetrics {
        completionUpdate()
        self?.uploadBodyMetricsBackGroundTask()
      }
    }
  }

  private func storeBodyMetrics(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.eventsUseCase.bodyMetricsStoreUseCase.execute()
      } catch { }
      completion()
    }
  }

  private func uploadBodyMetricsBackGroundTask() {
    if let eventUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask() {
      self.eventsUseCase.bodyMetricsTransmission.uploadEvents() { [weak self] _ in
        self?.handleEventsUploaded?(.bodyMetrics)
        UIApplication.shared.endBackgroundTask(eventUploadTask)
      }
    }
  }
}
