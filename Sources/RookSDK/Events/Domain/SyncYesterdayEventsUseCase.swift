//
//  SyncYesterdayEventsUseCase.swift
//  RookConnectAppleHealth
//
//  Created by Francisco Guerrero Escamilla on 19/12/23.
//

import Foundation

final class SyncYesterdayEventsUseCase {
  let physicalOxygenationUseCase: SyncPhysicalOxygenationUseCase = SyncPhysicalOxygenationUseCase()
  let bodyOxygenationUseCase: SyncBodyOxygenationUseCase = SyncBodyOxygenationUseCase()
  let physicalHeartRateUseCase: SyncPhysicalHeartRateEventsUseCase = SyncPhysicalHeartRateEventsUseCase()
  let activityUseCase: SyncActivityEventsUseCase = SyncActivityEventsUseCase()
  let bodyHeartRateUseCase: SyncBodyHeartRateEventsUseCase = SyncBodyHeartRateEventsUseCase()
  let pressureUseCase: SyncBloodPressureEventsUseCase = SyncBloodPressureEventsUseCase()
  let glucoseUseCase: SyncBloodGlucoseEventsUseCase = SyncBloodGlucoseEventsUseCase()
  let temperatureUseCase: SyncTemperatureEventsUseCase = SyncTemperatureEventsUseCase()
  
  func execute(completion: @escaping () -> Void) {
    
    let currentDate: Date = Date()
    guard let yesterdayDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else {
      return completion()
    }
    
    Task {
      
      // Oxygenation
      do {
        _ = try await uploadAsyncPhysicalOxygenation(yesterdayDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncBodyOxygenation(yesterdayDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncPhysicalOxygenation(currentDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncBodyOxygenation(currentDate)
      } catch {
      }
      
      // Heart Rate
      
      do {
        _ = try await uploadAsyncBodyHeartRate(yesterdayDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncPhysicalHeartRate(yesterdayDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncBodyHeartRate(currentDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncPhysicalHeartRate(currentDate)
      } catch {
      }
      
      // Activity
      
      do {
        _ = try await uploadAsyncActivity(yesterdayDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncActivity(currentDate)
      } catch {
      }
      
      // Blood Pressure
      
      do {
        _ = try await uploadAsyncBloodPressure(yesterdayDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncBloodPressure(currentDate)
      } catch {
      }
      
      // Blood Glucose
      
      do {
        _ = try await uploadAsyncBloodGlucose(yesterdayDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncBloodGlucose(currentDate)
      } catch {
      }
      
      // Temperature
      
      do {
        _ = try await uploadAsyncTemperature(yesterdayDate)
      } catch {
      }
      
      do {
        _ = try await uploadAsyncTemperature(currentDate)
      } catch {
      }
      
      completion()
      
    }
    
  }
}
