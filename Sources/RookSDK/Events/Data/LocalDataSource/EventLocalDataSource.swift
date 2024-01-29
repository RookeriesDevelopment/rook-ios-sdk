//
//  EventLocalDataSource.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 24/01/24.
//

import Foundation
import RookConnectTransmission

protocol EventLocalDataSourceProtocol {
  func getLastEventsUploadDate(for eventType: EventType) -> Date?
}

class EventLocalDataSource: EventLocalDataSourceProtocol {

  private let activityEventTransmissionManger: RookActivityEventTransmissionManager

  init(activityEventTransmissionManger: RookActivityEventTransmissionManager) {
    self.activityEventTransmissionManger = activityEventTransmissionManger
  }

  func getLastEventsUploadDate(for eventType: EventType) -> Date? {
    switch eventType {
    case .activityEvent:
      return activityEventTransmissionManger.getLastActivityEventTransmittedDate()
    }
  }
}
