import Foundation

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

#if canImport(UIKit)
    import UIKit

    extension Sequence {
        @available(iOS 13.0, *)
        func snapshot<Section: Hashable, Item: Hashable>() -> NSDiffableDataSourceSnapshot<Section, Item> where Element == SectionItemsModel<Section, Item> {
            reduce(into: NSDiffableDataSourceSnapshot<Section, Item>()) { snapshot, sectionModel in
                snapshot.appendSections([sectionModel.section])
                snapshot.appendItems(sectionModel.items, toSection: sectionModel.section)
            }
        }
    }
#endif
