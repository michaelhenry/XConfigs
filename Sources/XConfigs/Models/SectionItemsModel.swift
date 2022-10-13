import Foundation

struct SectionItemsModel<Section: Hashable, Item: Hashable>: Hashable {
    let section: Section
    let items: [Item]
}
