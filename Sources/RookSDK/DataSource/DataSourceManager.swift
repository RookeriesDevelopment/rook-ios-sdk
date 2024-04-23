//
//  DataSourceManager.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 22/04/24.
//

import Foundation
import RookUsersSDK

final public class DataSourcesManager {

  // MARK:  Properties

  private let dataSourceManager: RookDataSourceManager = RookDataSourceManager()

  // MARK:  init

  public init() { }

  // MARK:  Methods

  public func getAvailableDataSources(completion: @escaping (Result<[RookDataSource], Error>) -> Void) {
    dataSourceManager.getAvailableDataSources { result in
      switch result {
      case .success(let sources):
        completion(.success(sources.map({
          RookDataSource(
            name: $0.name,
            description: $0.description,
            imageUrl: $0.imageUrl,
            connected: $0.connected,
            authorizationURL: $0.authorizationURL)
        })))
      case .failure(let failure):
        completion(.failure(failure))
      }
    }
  }

  public func presentDataSourceView(completion: @escaping (Result<Bool, Error>) -> Void) {
    dataSourceManager.presentDataSourceView(completion: completion)
  }

}
