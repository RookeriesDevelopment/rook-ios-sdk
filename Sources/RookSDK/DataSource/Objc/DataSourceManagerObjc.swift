//
//  DataSourceManagerObjc.swift
//  RookSDK
//
//  Created by Francisco Guerrero Escamilla on 23/04/24.
//

import Foundation

@objc final public class DataSourceManagerObjc: NSObject {

  // MARK:  Properties

  private let dataSourceManager: DataSourcesManager = DataSourcesManager()
  private let mapper: EncodableMapper = EncodableMapper()

  // MARK:  init

  @objc public override init() { }

  // MARK:  Methods

  @objc public func getAvailableDataSources(completion: @escaping ([[String : Any]]?, Error?) -> Void) {
    dataSourceManager.getAvailableDataSources { [weak self] result in
      switch result {
      case .success(let sources):
        completion(self?.mapSourcesToDictionaryArray(sources), nil)
      case .failure(let failure):
        completion(nil, failure)
      }
    }
  }

  @objc public func presentDataSourceView(completion: @escaping (Bool, Error?) -> Void) {
    dataSourceManager.presentDataSourceView { result in
      switch result {
      case .success(let success):
        completion(success, nil)
      case .failure(let failure):
        completion(false, failure)
      }
    }
  }

  private func mapSourcesToDictionaryArray(_ sources: [RookDataSource]) -> [[String : Any]] {
    var dictionaryArray: [[String : Any]] = []
    for source in sources {
      do {
        dictionaryArray.append(try mapper.asDictionary(
          object: DataSource(
            name: source.name,
            description: source.description,
            imageUrl: source.imageUrl,
            connected: source.connected,
            authorizationURL: source.authorizationURL)
        ))
      } catch { }
    }
    return dictionaryArray
  }
}
