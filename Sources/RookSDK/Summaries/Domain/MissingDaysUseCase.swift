//
//  MissingDaysUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 17/01/24.
//

import Foundation

protocol MissingDaysUseCaseProtocol {
  func execute(for summaryType: SummaryType) async throws -> [Date]
}

final class MissingDaysUseCase: MissingDaysUseCaseProtocol {

  // MARK:  Properties
  
  private let localDataSource: SummaryLocalDataSourceProtocol
  private let previousDate: Int = -1
  private let minimumNumberOfMissingDays: Int = 1
  
  // MARK:  Init
  
  init(localDataSource: SummaryLocalDataSourceProtocol) {
    self.localDataSource = localDataSource
  }
  
  // MARK:  Methods
  
  func execute(for summaryType: SummaryType) async throws -> [Date] {
    return try getDates(summaryType)
  }

  private func getDates(_ summaryType: SummaryType) throws -> [Date] {
    let numberOfDays: Int = try self.getNumberOfMissingDays(summaryType)
    if numberOfDays >= 1 {
      return getDatesArray(summaryType,numberOfDays: numberOfDays)
    } else {
      return []
    }
  }
  
  private func getDatesArray(_ summaryType: SummaryType, numberOfDays: Int) -> [Date] {
    var dates: [Date] = []
    let start: Int = summaryType == .sleep ? 0 : 1
    let end: Int = summaryType == .sleep ? numberOfDays - 1 : numberOfDays
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

  private func getNumberOfMissingDays(_ summaryType: SummaryType) throws -> Int {
    guard let lastDate: Date = localDataSource.getLastSummaryUploadDate(for: summaryType),
          let yesterdayDate: Date = Calendar.current.date(
            byAdding: .day,
            value: summaryType == .sleep ? .zero : self.previousDate,
            to: Date()) else {
      return 7
    }
    let fromDate: Date = Calendar.current.startOfDay(for: lastDate)
    let toDate: Date = Calendar.current.startOfDay(for: yesterdayDate)
    guard let numberOfDays: Int = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day else {
      throw RookConnectErrors.nothingToUpdate
    }
    return numberOfDays > 7 ? 7 : numberOfDays
  }
}
