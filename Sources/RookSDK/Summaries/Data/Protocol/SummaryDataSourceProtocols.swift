//
//  SummaryDataSourceProtocols.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/01/24.
//

import Foundation

protocol SummaryLocalDataSourceProtocol {
  func getLastSummaryUploadDate(for summaryType: SummaryType) -> Date?
}
