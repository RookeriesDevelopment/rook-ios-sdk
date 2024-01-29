//
//  DatesHelper.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/01/24.
//

import Foundation

struct TimeConfiguration {
  let hours: Int
  let minutes: Int
  let seconds: Int
}

struct DateHelper {

  func getDateWithComponents(date: Date,
                             with timeComponents: TimeConfiguration,
                             timeZone: TimeZone? = .current) -> Date? {
    var calendar = Calendar.current
    calendar.timeZone = timeZone ?? .current
    let year = calendar.component(.year, from: date)
    let month =  (calendar.component(.month, from: date))
    let day = (calendar.component(.day, from: date))
    
    var dateComponents = DateComponents()
    
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = day
    dateComponents.hour = timeComponents.hours
    dateComponents.minute = timeComponents.minutes
    dateComponents.second = timeComponents.seconds
    
    let start: Date? = calendar.date(from: dateComponents)
    
    return start
  }

  func offsetInHours() -> Int {
    let hours = (TimeZone.current.secondsFromGMT()) / (3600)
    return hours
  }

}
