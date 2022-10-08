//
//  File.swift
//
//
//  Created by Michael Henry Pantaleon on 8/10/2022.
//

import Foundation

extension CaseIterable where Self: RawStringRepresentable {
    var allChoices: [String] {
        Self.allCases.compactMap(\.rawString)
    }
}
