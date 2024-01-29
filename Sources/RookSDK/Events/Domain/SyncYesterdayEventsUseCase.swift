//
//  SyncYesterdayEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/12/23.
//

import Foundation
import RookAppleHealth

final class SyncYesterdayEventsUseCase {
  
  struct UseCases {
    let physicalOxygenationUseCase: SyncPhysicalOxygenationUseCase
    let bodyOxygenationUseCase: SyncBodyOxygenationUseCase
    let physicalHeartRateUseCase: SyncPhysicalHeartRateEventsUseCase
    let activityUseCase: UploadMissingActivityEventsProtocol
    let bodyHeartRateUseCase: SyncBodyHeartRateEventsUseCase
    let pressureUseCase: SyncBloodPressureEventsUseCase
    let glucoseUseCase: SyncBloodGlucoseEventsUseCase
    let temperatureUseCase: SyncTemperatureEventsUseCase
    let lastExtractionUseCase: LastExtractionEventDateUseCase
  }

  let useCases: UseCases
  
  init(useCases: UseCases) {
    self.useCases = useCases
  }
  
  func execute(completion: @escaping () -> Void) {
    
    let currentDate: Date = Date()
    guard let yesterdayDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
      return completion()
    }
    
    Task {

      // Activity
      do {
        _ = try await self.useCases.activityUseCase.execute(upload: true)
      } catch {
      }
      
      // Oxygenation
      do {
        if isValidDateForUpdate(for: .oxygenationPhysicalEvent, forToday: false) {
          _ = try await uploadAsyncPhysicalOxygenation(yesterdayDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .oxygenationBodyEvent, forToday: false) {
          _ = try await uploadAsyncBodyOxygenation(yesterdayDate,
                                                   excludingDatesBefore: nil)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .oxygenationPhysicalEvent) {
          _ = try await uploadAsyncPhysicalOxygenation(currentDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .oxygenationBodyEvent) {
          _ = try await uploadAsyncBodyOxygenation(
            currentDate,
            excludingDatesBefore: useCases.lastExtractionUseCase.execute(
              type: .oxygenationBodyEvent))
        }
      } catch {
      }
      
      // Heart Rate
      
      do {
        if isValidDateForUpdate(for: .heartRateBodyEvent, forToday: false) {
          _ = try await uploadAsyncBodyHeartRate(yesterdayDate, excludingDatesBefore: nil)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .heartRatePhysicalEvent, forToday: false) {
          _ = try await uploadAsyncPhysicalHeartRate(yesterdayDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .heartRateBodyEvent) {
          _ = try await uploadAsyncBodyHeartRate(
            currentDate,
            excludingDatesBefore: useCases.lastExtractionUseCase.execute(
              type: .heartRateBodyEvent))
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .heartRatePhysicalEvent) {
          _ = try await uploadAsyncPhysicalHeartRate(currentDate)
        }
      } catch {
      }
      
      // Blood Pressure
      
      do {
        if isValidDateForUpdate(for: .bloodPressureEvent, forToday: false) {
          _ = try await uploadAsyncBloodPressure(yesterdayDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .bloodPressureEvent) {
          _ = try await uploadAsyncBloodPressure(currentDate)
        }
      } catch {
      }
      
      // Blood Glucose
      
      do {
        if isValidDateForUpdate(for: .bloodGlucoseEvent, forToday: false) {
          _ = try await uploadAsyncBloodGlucose(yesterdayDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .bloodGlucoseEvent) {
          _ = try await uploadAsyncBloodGlucose(currentDate)
        }
      } catch {
      }
      
      // Temperature
      
      do {
        if isValidDateForUpdate(for: .temperatureEvent, forToday: false) {
          _ = try await uploadAsyncTemperature(yesterdayDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .temperatureEvent) {
          _ = try await uploadAsyncTemperature(currentDate)
        }
      } catch {
      }
      
      completion()
      
    }
    
  }

  private func isValidDateForUpdate(for type: RookDataType, forToday: Bool = true) -> Bool {
    if let lastExtractionDate: Date = useCases.lastExtractionUseCase.execute(type: type) {
      let currentDate: Date = Date()
      let distance: TimeInterval = lastExtractionDate.distance(to: currentDate)
      let distanceHours: Int = Int(distance) / 3600
      let minimumTimeForUpdate: Int = forToday ? 1 : 24
      return distanceHours >= minimumTimeForUpdate
    } else {
      return true
    }
  }
}
