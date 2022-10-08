//
//  File.swift
//
//
//  Created by Michael Henry Pantaleon on 8/10/2022.
//

import Foundation

class RemoteConfigManager {
    static let manager = RemoteConfigManager()
    var valueProvider: RemoteConfigValueProvider = UserDefaults.standard
}
