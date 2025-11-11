// Copyright © 2025 Booket. All rights reserved

import BKDomain
import Combine
import Foundation
import FirebaseRemoteConfig

enum RemoteConfigKeys {
    static let latestVersion = "appleLatestVersion"
    static let minimumRequiredVersion = "appleMinimumVersion"
}

public struct DefaultRemoteConfigRepository: RemoteConfigRepository {

    private let remoteConfig: RemoteConfig
    
    public init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
        self.setDefaults()
    }
    
    public func fetchRemoteAppVersions() -> AnyPublisher<RemoteAppVersion, Error> {
        return Future<RemoteAppVersion, Error> { promise in
            self.remoteConfig.fetchAndActivate { status, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                if status != .error {
                    let latest = self.remoteConfig.configValue(
                        forKey: RemoteConfigKeys.latestVersion
                    ).stringValue
                    
                    let minimum = self.remoteConfig.configValue(
                        forKey: RemoteConfigKeys.minimumRequiredVersion
                    ).stringValue
                    
                    let versions = RemoteAppVersion(
                        latestVersion: latest,
                        minimumRequiredVersion: minimum
                    )
                    promise(.success(versions))
                } else {
                    promise(.failure(URLError(.cannotParseResponse)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func setDefaults() {
        let defaultValues: [String: NSObject] = [
            RemoteConfigKeys.latestVersion: "0.0.0" as NSObject,
            RemoteConfigKeys.minimumRequiredVersion: "0.0.0" as NSObject
        ]
        self.remoteConfig.setDefaults(defaultValues)
    }
}
