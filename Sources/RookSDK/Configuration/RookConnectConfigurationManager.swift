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

public final class RookConnectConfigurationManager {
  
  // MARK:  Properties
  
  public static let shared: RookConnectConfigurationManager = RookConnectConfigurationManager()
  
  private let usersConfigurator: RookUsersConfiguration = RookUsersConfiguration.shared
  private let extractionConfigurator: RookAuthAppleHealth = RookAuthAppleHealth.shared
  private let transmissionConfigurator: RookTransmissionSettings = RookTransmissionSettings.shared
  private let userManger: RookUsersManger = RookUsersManger()
  private let initUseCase: InitUseCaseProtocol = InitUseCase()
  private let timeZoneUseCase: TimeZoneUseCaseProtocol = TimeZoneUseCase()
  
  private var innerConfiguration: SDKConfiguration?
  
  // MARK:  Init
  
  private init() { }
  
  // MARK:  Helpers
  
  public func setConfiguration(urlAPI: String,
                               clientUUID: String,
                               secretKey: String) {
    
    self.usersConfigurator.setConfiration(urlAPI: urlAPI, clientUUID: clientUUID, secretKey: secretKey)
    self.extractionConfigurator.setClientUUID(with: clientUUID)
    self.transmissionConfigurator.setConfiguration(with: urlAPI, clientUUID: clientUUID, secretKey: secretKey)
    
    self.innerConfiguration = SDKConfiguration(
      urlAPI: urlAPI,
      clientUUID: clientUUID,
      secretKey: secretKey)
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
        self?.timeZoneUseCase.execute(completion: completion)
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }
  
  public func clearUser(completion: @escaping (Result<Bool, Error>) -> Void) {
    self.userManger.removeUser(compeltion: completion)
  }
  
  public func syncUserTimeZone(completion: @escaping (Result<Bool, Error>) -> Void) {
    timeZoneUseCase.execute(completion: completion)
  }
}
