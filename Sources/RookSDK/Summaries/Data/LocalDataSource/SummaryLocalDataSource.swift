//
//  SummaryLocalDataSource.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/01/24.
//

import Foundation
import RookConnectTransmission
import RookAppleHealth

class SummaryLocalDataSource: SummaryLocalDataSourceProtocol {

  private let sleepTransmissionManger: RookSleepTransmissionManager
  private let physicalTransmissionManger: RookPhysicalTransmissionManager
  private let bodyTransmissionManger: RookBodyTransmissionManager

  init(sleepTransmissionManger: RookSleepTransmissionManager, physicalTransmissionManger: RookPhysicalTransmissionManager, bodyTransmissionManger: RookBodyTransmissionManager) {
    self.sleepTransmissionManger = sleepTransmissionManger
    self.physicalTransmissionManger = physicalTransmissionManger
    self.bodyTransmissionManger = bodyTransmissionManger
  }

  func getLastSummaryUploadDate(for summaryType: SummaryType) -> Date? {
    switch summaryType {
    case .sleep:
      return sleepTransmissionManger.getLastSleepSummaryTransmittedDate()
    case .physical:
      return physicalTransmissionManger.getLastPhysicalSummaryTransmittedDate()
    case .body:
      return bodyTransmissionManger.getLastBodySummaryTransmittedDate()
    }
  }
}
