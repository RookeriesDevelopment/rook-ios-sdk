//
//  Events+Objc.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 28/08/23.
//

import Foundation

extension RookEventsManager {
  
  @objc public func syncBodyHeartRateEventObjc(date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncBodyHeartRateEvent(date: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncPhysicalHeartRateEventObjc(date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncPhysicalHeartRateEvent(date: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncBodyOxygenationEventObjc(date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncBodyOxygenationEvent(date: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncPhysicalOxygenationEventObjc(date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncPhysicalOxygenationEvent(date: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncTrainingEventObjc(date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncTrainingEvent(date: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncTemperatureEventsObjc(date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncTemperatureEvents(date: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncPressureEventsObjc(date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncBloodPressureEvents(date: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncGlucoseEventsObjc(date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncBloodGlucoseEvents(date: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc func syncPendingEventsObjc(completion: @escaping (Bool, Error?) -> Void) {
    self.syncPendingEvents() { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
}
