//
//  Permissions+Objc.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 28/08/23.
//

import Foundation

extension RookConnectPermissionsManager {
  
  @objc public func requestAllPermissionsObjc(completion: @escaping (Bool, Error?) -> Void) {
    self.requestAllPermissions() { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let error):
        completion(false, error)
      }
    }
  }
  
  @objc public func requestSleepPermissionsObjc(completion: @escaping (Bool, Error?) -> Void) {
    self.requestSleepPermissions() { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let error):
        completion(false, error)
      }
    }
  }
  
  @objc public func requestUserInfoPermissionsObjc(completion: @escaping (Bool, Error?) -> Void) {
    self.requestUserInfoPermissions() { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let error):
        completion(false, error)
      }
    }
  }
  
  @objc public func requestPhysicalPermissionsObjc(completion: @escaping (Bool, Error?) -> Void) {
    self.requestPhysicalPermissions() { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let error):
        completion(false, error)
      }
    }
  }
  
  @objc public func requestBodyPermissionsObjc(completion: @escaping (Bool, Error?) -> Void) {
    self.requestBodyPermissions() { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let error):
        completion(false, error)
      }
    }
  }  
}
