//
//  IOSClass.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 25/10/23.
//

import Foundation
import RookUsersSDK
import RookAppleHealth
import RookConnectTransmission

@objc final public class IOSClass: NSObject {
  
  // MARK:  Properties
  
  @objc public static let shared: IOSClass = IOSClass()
  
  private var isInnerTestEnable: Bool = false
  
  var isTestEnable: Bool {
    return isInnerTestEnable
  }
  
  // MARK:  Init
  
  private override init() {
  }
  
  // MARK:  Helpers
  
  @objc public func test() {
    isInnerTestEnable = true
    UsersIOSClass.shared.test()
    ExtractionIOSClass.shared.test()
    TransmissionIOSClass.shared.test()
  }
  
  @objc public func disableTest() {
    isInnerTestEnable = false
    UsersIOSClass.shared.diableTest()
    ExtractionIOSClass.shared.diableTest()
    TransmissionIOSClass.shared.diableTest()
  }
  
}
