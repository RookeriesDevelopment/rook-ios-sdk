//
//  RookConnectConfigurationManager.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 16/08/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission
import RookUsersSDK
import UIKit

public final class RookConnectConfigurationManager {
  
  // MARK:  Properties
  
  public static let shared: RookConnectConfigurationManager = RookConnectConfigurationManager()
  
  private let usersConfigurator: RookUsersConfiguration = RookUsersConfiguration.shared
  private let extractionConfigurator: RookAuthAppleHealth = RookAuthAppleHealth.shared
  private let transmissionConfigurator: RookTransmissionSettings = RookTransmissionSettings.shared
  private let userManger: RookUsersManger = RookUsersManger()
  private let initUseCase: InitUseCaseProtocol = InitUseCase()
  private let timeZoneUseCase: TimeZoneUseCaseProtocol = TimeZoneUseCase()
  private let syncManager: RookSummaryManger = RookSummaryManger()
  private let eventsManager: RookEventsManager = RookEventsManager()
  private let foregroundSyncLocalDataSource: ForegroundSyncLocalDataSource = ForegroundSyncLocalDataSource()
  
  private var innerConfiguration: SDKConfiguration?
  
  private var innerEnvironment: RookEnvironment = .sandbox

  private var observer: NSObjectProtocol?
  
  // UIApplicationWillEnterForegroundNotification
  
  // MARK:  Init
  
  private init() {
    self.addObserver()
  }
  
  // MARK:  Helpers
  
  public func setConfiguration(clientUUID: String,
                               secretKey: String) {
    
    self.usersConfigurator.setConfiguration(
      clientUUID: clientUUID,
      secretKey: secretKey)
    
    self.extractionConfigurator.setClientUUID(
      with: clientUUID,
      secretKey: secretKey)
    
    self.transmissionConfigurator.setConfiguration(
      clientUUID: clientUUID,
      secretKey: secretKey)
    
    self.innerConfiguration = SDKConfiguration(
      clientUUID: clientUUID,
      secretKey: secretKey)
  }
  
  public func setEnvironment(_ environment: RookEnvironment) {
    switch environment {
    case .sandbox:
      self.usersConfigurator.setEnvironment(.sandbox)
      self.extractionConfigurator.setEnvironment(.sandbox)
      self.transmissionConfigurator.setEnvironment(.sandbox)
    case .production:
      self.usersConfigurator.setEnvironment(.production)
      self.extractionConfigurator.setEnvironment(.production)
      self.transmissionConfigurator.setEnvironment(.production)
    }
  }
  
  public func initRook() {
    self.usersConfigurator.initRookUsers() { _ in }
    self.extractionConfigurator.initRookAH()
    self.transmissionConfigurator.initRookTransmission()
  }
  
  public func initRook(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.initUseCase.execute(configuration: self.innerConfiguration, completion: completion)
  }
  
  public func updateUserId(_ id: String,
                           completion: @escaping (Result<Bool, Error>) -> Void) {
    self.userManger.registerRookUser(with: id) { [weak self] result in
      switch result {
      case .success(let success):
        completion(.success(success))
        self?.timeZoneUseCase.execute { _ in }
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  public func getUserId(completion: @escaping (Result<String, Error>) -> Void) {
    self.userManger.getUserIdStored(completion: completion)
  }
  
  public func clearUser(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.userManger.removeUser(completion: completion)
  }
  
  public func removeUserFromRook(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.userManger.removeUserFromRook(completion: completion)
  }
  
  public func syncUserTimeZone(completion: @escaping (Result<Bool, Error>) -> Void) {
    timeZoneUseCase.execute(completion: completion)
  }
  
  @available(*, deprecated, renamed: "enableSync")
  public func enableYesterdaySync() {
    foregroundSyncLocalDataSource.setForegroundEnable(with: true)
  }

  public func enableSync() {
    foregroundSyncLocalDataSource.setForegroundEnable(with: true)
  }

  @available(*, deprecated, renamed: "disableSync")
  public func disableYesterdaySync() {
    foregroundSyncLocalDataSource.setForegroundEnable(with: false)
  }

  public func disableSync() {
    foregroundSyncLocalDataSource.setForegroundEnable(with: false)
  }

  @available(*, deprecated, renamed: "isSyncEnable")
  public func isYesterdaySyncEnable() -> Bool {
    return foregroundSyncLocalDataSource.isForegroundSyncEnable()
  }

  public func isSyncEnable() -> Bool {
    return foregroundSyncLocalDataSource.isForegroundSyncEnable()
  }

  // MARK:  Private
  
  private func addObserver() {
    observer = NotificationCenter.default.addObserver(
      forName: UIApplication.willEnterForegroundNotification,
      object: nil,
      queue: .main) { [weak self] notification in
        guard let self: RookConnectConfigurationManager = self else {
          return
        }
        if self.foregroundSyncLocalDataSource.isForegroundSyncEnable() {
          self.syncManager.syncSummaries {}
          self.eventsManager.syncEvents {}
        }
    }
  }
}
