//
//  Summaries+Objc.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 28/08/23.
//

import Foundation

extension RookSummaryManager {
  
  @objc public func syncSleepSummaryObjc(form date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncSleepSummary(from: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncPhysicalSummaryObjc(form date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncPhysicalSummary(from: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncBodySummaryObjc(from date: Date, completion: @escaping (Bool, Error?) -> Void) {
    self.syncBodySummary(from: date) { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
  @objc public func syncPendingSummariesObjc(completion: @escaping (Bool, Error?) -> Void) {
    self.syncPendingSummaries() { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }
  
}
