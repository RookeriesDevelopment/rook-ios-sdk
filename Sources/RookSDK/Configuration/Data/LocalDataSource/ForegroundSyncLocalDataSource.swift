//
//  ForegroundSyncLocalDataSource.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 04/01/24.
//

import Foundation

class ForegroundSyncLocalDataSource {
  
  // MARK:  Properties
  
  private let defaults: UserDefaults = UserDefaults.standard
  private let constants: ForeGroundConstants = ForeGroundConstants()
  
  // MARK:  Helpers
  
  func setForegroundEnable(with value: Bool) {
    defaults.set(value, forKey: constants.isForeGroundSyncEnable)
  }
  
  func isForegroundSyncEnable() -> Bool {
    return defaults.bool(forKey: constants.isForeGroundSyncEnable)
  }
  
}
