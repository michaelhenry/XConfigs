//
//  File.swift
//
//
//  Created by Michael Henry Pantaleon on 8/10/2022.
//

import Foundation

extension String: RawStringRepresentable {
    var rawString: String {
        self
    }

    init(rawString: String) {
        self = rawString
    }
}
