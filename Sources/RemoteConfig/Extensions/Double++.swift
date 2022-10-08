//
//  File.swift
//
//
//  Created by Michael Henry Pantaleon on 8/10/2022.
//

import Foundation

extension Double: RawStringRepresentable {
    var rawString: String {
        "\(self)"
    }

    init(rawString: String) {
        self = Double(rawString) ?? 0.0
    }
}
