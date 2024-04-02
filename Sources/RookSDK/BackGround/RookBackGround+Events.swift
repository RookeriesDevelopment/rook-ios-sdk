//
//  RookBackGround+Events.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 24/01/24.
//

import Foundation
import RookAppleHealth
import UIKit

extension RookBackGroundSync {

  @objc public func enableBackGroundForActivityEvents() {
    handleRequestActivityEventsData?()
  }

  @objc public func enableBackGroundForEvents() {
    handleRequestActivityEventsData?()
    handleRequestEventsData?()
  }

  public func disableBackGroundForActivityEvents(completion: @escaping (Result<Bool, Error>) -> Void) {
    backGroundManager.setBackGroundDisable(for: .activityEventsBackGroundExtractionEnable)
    backGroundManager.setBackGroundDisable(for: .eventsBackGroundExtractionEnable)
    backGroundManager.disableBackGround(for: .workout, completion: completion)
  }

  @objc public func disableBackGroundForEvents() {
    backGroundManager.setBackGroundDisable(for: .eventsBackGroundExtractionEnable)
  }

  func activityEventsBackListener() {
    backGroundManager.isBackgroundEnable(for: .activityEventsBackGroundExtractionEnable) { [weak self] (isEnable) in
      if isEnable {
        self?.setBackGround()
      } else {
        self?.handleRequestActivityEventsData = {
          self?.backGroundManager.setBackGroundEnable(for: .activityEventsBackGroundExtractionEnable)
          self?.setBackGround()
        }
      }
    }
    
    backGroundManager.isBackgroundEnable(for: .eventsBackGroundExtractionEnable) { [weak self] (isEnable) in
      if isEnable {
        self?.setBackGroundEventListeners()
      } else {
        self?.handleRequestEventsData = {
          self?.backGroundManager.setBackGroundEnable(for: .eventsBackGroundExtractionEnable)
          self?.setBackGroundEventListeners()
        }
      }
    }
  }

  private func setBackGround() {
    backGroundManager.setBackGroundListener(type: .workout) { [weak self] (completionUpdate, error) in
      self?.storeMissing {
        completionUpdate()
        self?.initUploadBackgroundTask()
      }
    }
  }

  private func initUploadBackgroundTask() {
    if let summariesUploadTask: UIBackgroundTaskIdentifier = initiateBackgroundTask() {
      self.activityTransmissionManager.uploadEvents { [weak self] _ in
        self?.handleActivityEventsUploaded?()
        self?.handleEventsUploaded?(.workout)
        UIApplication.shared.endBackgroundTask(summariesUploadTask)
      }
    }
  }

  private func storeMissing(completion: @escaping () -> Void) {
    Task {
      do {
        _ = try await self.activityMissingEvents.execute(upload: false)
        completion()
      } catch {
        completion()
      }
    }
  }
}
