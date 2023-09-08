//
//  RookConnectErrors.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 18/08/23.
//

import Foundation

public enum RookConnectErrors: Error {
  case empySummary
  case emptySummaries
  case emptyEvent
  case nothingToUpdate
  case missingConfigurtion
}
