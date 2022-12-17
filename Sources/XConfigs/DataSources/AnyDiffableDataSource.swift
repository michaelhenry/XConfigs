import DiffableDataSources
import Foundation
import UIKit

@available(iOS 13.0, *)
private class TableViewDataSource<Section: Hashable, Item: Hashable>: UITableViewDiffableDataSource<Section, Item> {
    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        "\(snapshot().sectionIdentifiers[section])"
    }
}

private class LegacyTableViewDataSource<Section: Hashable, Item: Hashable>: TableViewDiffableDataSource<Section, Item> {
    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        "\(snapshot().sectionIdentifiers[section])"
    }
}

struct AnyDiffableDataSource<Section: Hashable, Item: Hashable> {
    private let datasource: Any?

    init(tableView: UITableView, cellProvider: @escaping (UITableView, IndexPath, Item) -> UITableViewCell?) {
        if #available(iOS 13.0, *) {
            let ds = TableViewDataSource<Section, Item>(tableView: tableView, cellProvider: cellProvider)
            ds.defaultRowAnimation = .fade
            datasource = ds
        } else {
            let ds = LegacyTableViewDataSource<Section, Item>(tableView: tableView, cellProvider: cellProvider)
            ds.defaultRowAnimation = .fade
            datasource = ds
        }
    }

    func applyAnySnapshot(_ snapshot: Any, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *) {
            guard let datasource = datasource as? TableViewDataSource<Section, Item>, let snapshot = snapshot as? NSDiffableDataSourceSnapshot<Section, Item> else { return }
            datasource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        } else {
            guard let datasource = datasource as? LegacyTableViewDataSource<Section, Item>, let snapshot = snapshot as? DiffableDataSourceSnapshot<Section, Item> else { return }
            datasource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        }
    }

    func itemIdentifier(for indexPath: IndexPath) -> Item? {
        if #available(iOS 13.0, *) {
            guard let datasource = datasource as? TableViewDataSource<Section, Item> else { return nil }
            return datasource.itemIdentifier(for: indexPath)
        } else {
            guard let datasource = datasource as? LegacyTableViewDataSource<Section, Item> else { return nil }
            return datasource.itemIdentifier(for: indexPath)
        }
    }
}

extension Sequence {
    func anySnapshot<Section: Hashable, Item: Hashable>() -> Any where Element == SectionItemsModel<Section, Item> {
        if #available(iOS 13.0, *) {
            return snapshot()
        } else {
            return snapshotLegacy()
        }
    }
}
