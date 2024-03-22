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

  private let transmissionLocalDataSource: TransmissionLocalDataSource

  init(transmissionLocalDataSource: TransmissionLocalDataSource) {
    self.transmissionLocalDataSource = transmissionLocalDataSource
  }

  func getLastEventsUploadDate(for eventType: EventType) -> Date? {
    switch eventType {
    case .activityEvent:
      return transmissionLocalDataSource.getLastEventTransmissionDate(of: .activityEvent)
    case .bodyHr:
      return transmissionLocalDataSource.getLastEventTransmissionDate(of: .heartRateBodyEvent)
    case .physicalHr:
      return transmissionLocalDataSource.getLastEventTransmissionDate(of: .heartRatePhysicalEvent)
    case .bodyOxygenation:
      return transmissionLocalDataSource.getLastEventTransmissionDate(of: .oxygenationBodyEvent)
    case .physicalOxygenation:
      return transmissionLocalDataSource.getLastEventTransmissionDate(of: .oxygenationPhysicalEvent)
    case .temperature:
      return transmissionLocalDataSource.getLastEventTransmissionDate(of: .temperatureEvent)
    case .bloodPressure:
      return transmissionLocalDataSource.getLastEventTransmissionDate(of: .bloodPressureEvent)
    case .bloodGlucose:
      return transmissionLocalDataSource.getLastEventTransmissionDate(of: .bloodGlucoseEvent)
    case .bodyMetrics:
      return transmissionLocalDataSource.getLastEventTransmissionDate(of: .bodyMetricsEvent)
    }
  }
}
