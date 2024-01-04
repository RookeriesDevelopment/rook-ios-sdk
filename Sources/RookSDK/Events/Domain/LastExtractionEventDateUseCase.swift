//
//  LastExtractionEventDateUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 03/01/24.
//

import Foundation
import RookAppleHealth

class LastExtractionEventDateUseCase {

  private let extractionManager: RookExtractionEventManager = RookExtractionEventManager()

  func execute(type: RookDataType) -> Date? {
    return extractionManager.getLastExtractionDate(of: type)
  }
}
