//
//  TimeZoneMapper.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 20/09/23.
//

import Foundation
import RookAppleHealth

struct TimeZoneMapper {
  
  static func mapTimeZone(_ userTimeZone: UserTimeZone) -> UserTimeZoneDTO {
    return UserTimeZoneDTO(
      timeZone: userTimeZone.timeZone,
      offset: userTimeZone.offset)
  }
  
}
