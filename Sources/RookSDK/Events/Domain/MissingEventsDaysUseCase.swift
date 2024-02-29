//
//  MissingEventsDaysUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 24/01/24.
//

import Foundation

protocol MissingEventsDaysUseCaseProtocol {
  func execute(for eventType: EventType) async throws -> [Date]
}

final class MissingEventsDaysUseCase: MissingEventsDaysUseCaseProtocol {

  // MARK:  Properties
  
  private let localDataSource: EventLocalDataSourceProtocol
  private let minimumNumberOfMissingDays: Int = 0
  
  // MARK:  Init
  
  init(localDataSource: EventLocalDataSourceProtocol) {
    self.localDataSource = localDataSource
  }
  
  // MARK:  Methods
  
  func execute(for eventType: EventType) async throws -> [Date] {
    return try getDates(eventType)
  }

  private func getDates(_ eventType: EventType) throws -> [Date] {
    let numberOfDays: Int = try self.getNumberOfMissingDays(eventType)
    if numberOfDays >= minimumNumberOfMissingDays {
      return getDatesArray(eventType, numberOfDays: numberOfDays)
    } else {
      return []
    }
  }
  
  private func getDatesArray(_ eventType: EventType, numberOfDays: Int) -> [Date] {
    var dates: [Date] = []
    let start: Int = 0
    let end: Int = numberOfDays
    for dayNumber in start...end {
      guard let dateToAdd = Calendar.current.date(
        byAdding: .day,
        value: -dayNumber,
        to: Date()) else {
        continue
      }
      dates.append(dateToAdd)
    }
    return dates
  }

  private func getNumberOfMissingDays(_ eventType: EventType) throws -> Int {
    guard let lastDate: Date = localDataSource.getLastEventsUploadDate(for: eventType) else {
      return 14
    }
    let fromDate: Date = lastDate
    let toDate: Date = Date()
    guard let numberOfDays: Int = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day else {
      throw RookConnectErrors.nothingToUpdate
    }
    return numberOfDays > 14 ? 14 : numberOfDays
  }
}
