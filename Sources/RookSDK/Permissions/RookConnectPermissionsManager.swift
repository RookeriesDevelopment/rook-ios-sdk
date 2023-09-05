//
//  RookConnectPermissionsManager.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 16/08/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission

@objc public final class RookConnectPermissionsManager: NSObject {
  
  // MARK:  Properties
  
  private let permissionsManger: RookPermissionExtraction = RookPermissionExtraction()
  
  // MARK:  Init
  
  @objc public override init() {
  }
  
  // MARK:  Helpers
  
  public func requestAllPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
    permissionsManger.requestAllPermissions(completion: completion)
  }
  
  public func requestSleepPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
    permissionsManger.requestSleepPermissions(completion: completion)
  }
  
  public func requestUserInfoPersmissions(completion: @escaping (Result<Bool, Error>) -> Void) {
    permissionsManger.requestUserInfoPersmissions(completion: completion)
  }
  
  public func requestPhysicalPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
    permissionsManger.requestPhysicalPermissions(completion: completion)
  }
  
  public func requesBodyPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
    permissionsManger.requesBodyPermissions(completion: completion)
  }
  
  
}
