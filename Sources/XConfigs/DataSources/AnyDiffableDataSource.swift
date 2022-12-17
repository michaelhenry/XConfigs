import DiffableDataSources
import Foundation
import UIKit

struct AnyDiffableDataSource<Section: Hashable, Item: Hashable> {
    private let datasource: Any?

    init(tableView: UITableView, cellProvider: @escaping (UITableView, IndexPath, Item) -> UITableViewCell?) {
        if #available(iOS 13.0, *) {
            let ds = UITableViewDiffableDataSource<Section, Item>(tableView: tableView, cellProvider: cellProvider)
            ds.defaultRowAnimation = .fade
            datasource = ds
        } else {
            let ds = TableViewDiffableDataSource<Section, Item>(tableView: tableView, cellProvider: cellProvider)
            ds.defaultRowAnimation = .fade
            datasource = ds
        }
    }

    func applyAnySnapshot(_ snapshot: Any, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *) {
            guard let datasource = datasource as? UITableViewDiffableDataSource<Section, Item>, let snapshot = snapshot as? NSDiffableDataSourceSnapshot<Section, Item> else { return }
            datasource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        } else {
            guard let datasource = datasource as? TableViewDiffableDataSource<Section, Item>, let snapshot = snapshot as? DiffableDataSourceSnapshot<Section, Item> else { return }
            datasource.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        }
    }

    func itemIdentifier(for indexPath: IndexPath) -> Item? {
        if #available(iOS 13.0, *) {
            guard let datasource = datasource as? UITableViewDiffableDataSource<Section, Item> else { return nil }
            return datasource.itemIdentifier(for: indexPath)
        } else {
            guard let datasource = datasource as? TableViewDiffableDataSource<Section, Item> else { return nil }
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
