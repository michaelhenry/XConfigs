//
//  SectionItemsModel.swift
//
//
//  Created by Michael Henry Pantaleon on 8/10/2022.
//

import Foundation

struct SectionItemsModel<Section: Hashable, Item: Hashable>: Hashable {
    let section: Section
    let items: [Item]
}
