//
//  RookConnectConfigurationManagerObjc.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 28/08/23.
//

import Foundation
import RookUsersSDK

@objc final public class RookConnectConfigurationManagerObjc: NSObject {
  
  // MARK:  Properties
  
  @objc public static let shared: RookConnectConfigurationManagerObjc = RookConnectConfigurationManagerObjc()
  
  private let innerConfiguration: RookConnectConfigurationManager = RookConnectConfigurationManager.shared
  
  private let usersManger: RookUsersManger = RookUsersManger()
  
  // MARK:  Init
  
  private override init() {
  }
  
  // MARK:  Helpers
  
  @objc public func setConfiguration(clientUUID: String,
                                     secretKey: String) {
    self.innerConfiguration.setConfiguration(
      clientUUID: clientUUID,
      secretKey: secretKey)
  }
  
  @objc public func setEnvironmentForSandbox() {
    self.innerConfiguration.setEnvironment(.sandbox)
  }
  
  @objc public func setEnvironmentForProduction() {
    self.innerConfiguration.setEnvironment(.production)
  }
  
  @objc public func initRook() {
    self.innerConfiguration.initRook()
  }
  
  @objc public func updateUserId(_ id: String,
                           completion: @escaping (Bool, Error?) -> Void) {
    self.innerConfiguration.updateUserId(id) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func readUserId(completion: @escaping (String?, Error?) -> Void) {
    usersManger.getUserIdStored() { result in
      switch result {
      case .success(let id):
        completion(id, nil)
      case .failure(let error):
        completion(nil, error)
      }
    }
  }
  
  @objc public func clearUser(completion: @escaping (Bool, Error?) -> Void) {
    self.innerConfiguration.clearUser() { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func removeUserFromRook(completion: @escaping (Bool, Error?) -> Void) {
    self.innerConfiguration.removeUserFromRook { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncUserTimeZone(completion: @escaping (Bool, Error?) -> Void) {
    self.innerConfiguration.syncUserTimeZone() { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }

  @available(*, deprecated, renamed: "enableSync")
  @objc public func enableYesterdaySync() {
    self.innerConfiguration.enableSync()
  }

  @objc public func enableSync() {
    self.innerConfiguration.enableSync()
  }

  @available(*, deprecated, renamed: "disableSync")
  @objc public func disableYesterdaySync() {
    self.innerConfiguration.disableSync()
  }

  @objc public func disableSync() {
    self.innerConfiguration.disableSync()
  }

  @available(*, deprecated, renamed: "isSyncEnable")
  @objc public func isYesterdaySyncEnable() -> Bool {
    return innerConfiguration.isSyncEnable()
  }

  @objc public func isSyncEnable() -> Bool {
    return innerConfiguration.isSyncEnable()
  }

  @objc public func setConsoleLogAvailable(_ value: Bool) {
    self.innerConfiguration.setConsoleLogAvailable(value)
  }

}
