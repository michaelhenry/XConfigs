//
//  File.swift
//
//
//  Created by Michael Henry Pantaleon on 8/10/2022.
//

import Foundation

extension Int: RawStringRepresentable {
    var rawString: String {
        "\(self)"
    }

    init(rawString: String) {
        self = Int(rawString) ?? 0
    }
}
