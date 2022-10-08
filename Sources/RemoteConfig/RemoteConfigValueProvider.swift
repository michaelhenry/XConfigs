//
//  File.swift
//
//
//  Created by Michael Henry Pantaleon on 8/10/2022.
//

import Foundation

protocol RemoteConfigValueProvider {
    func get<Value>(key: String) -> Value?
}
