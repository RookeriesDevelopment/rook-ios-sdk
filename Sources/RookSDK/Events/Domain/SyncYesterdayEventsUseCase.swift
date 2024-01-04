//
//  SyncYesterdayEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/12/23.
//

import Foundation
import RookAppleHealth

final class SyncYesterdayEventsUseCase {
  let physicalOxygenationUseCase: SyncPhysicalOxygenationUseCase = SyncPhysicalOxygenationUseCase()
  let bodyOxygenationUseCase: SyncBodyOxygenationUseCase = SyncBodyOxygenationUseCase()
  let physicalHeartRateUseCase: SyncPhysicalHeartRateEventsUseCase = SyncPhysicalHeartRateEventsUseCase()
  let activityUseCase: SyncActivityEventsUseCase = SyncActivityEventsUseCase()
  let bodyHeartRateUseCase: SyncBodyHeartRateEventsUseCase = SyncBodyHeartRateEventsUseCase()
  let pressureUseCase: SyncBloodPressureEventsUseCase = SyncBloodPressureEventsUseCase()
  let glucoseUseCase: SyncBloodGlucoseEventsUseCase = SyncBloodGlucoseEventsUseCase()
  let temperatureUseCase: SyncTemperatureEventsUseCase = SyncTemperatureEventsUseCase()
  let lastExtractionUseCase: LastExtractionEventDateUseCase = LastExtractionEventDateUseCase()
  
  func execute(completion: @escaping () -> Void) {
    
    let currentDate: Date = Date()
    guard let yesterdayDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
      return completion()
    }
    
    Task {
      
      // Oxygenation
      do {
        if isValidDateForUpdate(for: .oxygenationPhysicalEvent) {
          _ = try await uploadAsyncPhysicalOxygenation(yesterdayDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .oxygenationBodyEvent) {
          _ = try await uploadAsyncBodyOxygenation(yesterdayDate)
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
          _ = try await uploadAsyncBodyOxygenation(currentDate)
        }
      } catch {
      }
      
      // Heart Rate
      
      do {
        if isValidDateForUpdate(for: .heartRateBodyEvent) {
          _ = try await uploadAsyncBodyHeartRate(yesterdayDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .heartRatePhysicalEvent) {
          _ = try await uploadAsyncPhysicalHeartRate(yesterdayDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .heartRateBodyEvent) {
          _ = try await uploadAsyncBodyHeartRate(currentDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .heartRatePhysicalEvent) {
          _ = try await uploadAsyncPhysicalHeartRate(currentDate)
        }
      } catch {
      }
      
      // Activity
      
      do {
        if isValidDateForUpdate(for: .activityEvent) {
          _ = try await uploadAsyncActivity(yesterdayDate)
        }
      } catch {
      }
      
      do {
        if isValidDateForUpdate(for: .activityEvent) {
          _ = try await uploadAsyncActivity(currentDate)
        }
      } catch {
      }
      
      // Blood Pressure
      
      do {
        if isValidDateForUpdate(for: .bloodPressureEvent) {
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
        if isValidDateForUpdate(for: .bloodGlucoseEvent) {
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
        if isValidDateForUpdate(for: .temperatureEvent) {
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

  private func isValidDateForUpdate(for type: RookDataType) -> Bool {
    if let lastExtractionDate: Date = lastExtractionUseCase.execute(type: type) {
      let currentDate: Date = Date()
      let distance: TimeInterval = lastExtractionDate.distance(to: currentDate)
      let distanceHours: Int = Int(distance) / 3600
      return distanceHours > 1
    } else {
      return true
    }
  }
}
