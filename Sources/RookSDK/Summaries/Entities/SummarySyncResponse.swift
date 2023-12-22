//
//  SummarySyncResponse.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/12/23.
//

import Foundation

public struct SummarySyncResponse {
  public var sleepResponse: Result<Bool, Error>?
  public var physicalResponse: Result<Bool, Error>?
  public var bodyResponse: Result<Bool, Error>?
}
