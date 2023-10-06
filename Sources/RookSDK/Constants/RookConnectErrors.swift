//
//  RookConnectErrors.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 18/08/23.
//

import Foundation

public enum RookConnectErrors: Error {
  case emptySummary
  case emptySummaries
  case emptyEvent
  case nothingToUpdate
  case missingConfiguration
}

extension RookConnectErrors : LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .emptySummary:
      return "empty data for this summary"
    case .emptySummaries:
      return "the are not summaries stored"
    case .emptyEvent:
      return "empty data for events"
    case .nothingToUpdate:
      return "there is not data to be uploaded"
    case .missingConfiguration:
      return "first add the sdk configuration"
    }
  }
}
