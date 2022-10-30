import UIKit

struct SectionItemsModel<Section: Hashable, Item: Hashable>: Hashable {
    var section: Section
    var items: [Item]
}

// MARK: Equatable

extension SectionItemsModel: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.section == rhs.section && lhs.items == rhs.items
    }
}

// MARK: - SectionItemsModel + NSDiffableDataSourceSnapshot

extension SectionItemsModel {
    mutating func appendItems(items: [Item]) {
        self.items.append(contentsOf: items)
    }
}

extension Sequence {
    func snapshot<Section: Hashable, Item: Hashable>() -> NSDiffableDataSourceSnapshot<Section, Item> where Element == SectionItemsModel<Section, Item> {
        reduce(into: NSDiffableDataSourceSnapshot<Section, Item>()) { snapshot, sectionModel in
            snapshot.appendSections([sectionModel.section])
            snapshot.appendItems(sectionModel.items, toSection: sectionModel.section)
        }
    }
}
