//
//  InitUseCase.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 05/09/23.
//

import Foundation
import RookAppleHealth
import RookConnectTransmission
import RookUsersSDK

protocol InitUseCaseProtocol {
  func execute(configuration: SDKConfiguration?,
               completion: @escaping (Result<Bool, Error>) -> Void)
}

final class InitUseCase: InitUseCaseProtocol {
  
  // MARK:  Properties
  
  private let usersConfigurator: RookUsersConfiguration = RookUsersConfiguration.shared
  private let extractionConfigurator: RookAuthAppleHealth = RookAuthAppleHealth.shared
  private let transmissionConfigurator: RookTransmissionSettings = RookTransmissionSettings.shared
  
  // MARK:  Helpers
  
  func execute(configuration: SDKConfiguration?,
               completion: @escaping (Result<Bool, Error>) -> Void) {
    
    do {
      try validateConfiguration(configuration: configuration)
      self.initSDK(completion: completion)
    } catch {
      completion(.failure(error))
    }
    
  }
  
  private func validateConfiguration(configuration: SDKConfiguration?) throws {
    guard let configuration: SDKConfiguration = configuration else {
      throw RookConnectErrors.missingConfiguration
    }
    
    if configuration.secretKey.isEmpty || configuration.clientUUID.isEmpty {
      throw RookConnectErrors.missingConfiguration
    }
  }
  
  private func initSDK(completion: @escaping (Result<Bool, Error>) -> Void) {
    
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    dispatchGroup.enter()
    usersConfigurator.initRookUsers() { _ in
      dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    extractionConfigurator.initRookAH() { _ in
      dispatchGroup.leave()
    }
    
    dispatchGroup.enter()
    transmissionConfigurator.initRookTransmission() { _ in
      dispatchGroup.leave()
    }
    
    dispatchGroup.notify(queue: .main) {
      completion(.success(true))
    }
    
  }
  
}
