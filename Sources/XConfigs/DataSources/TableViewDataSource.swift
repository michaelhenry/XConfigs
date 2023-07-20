import UIKit

final class TableViewDataSource<Section: Hashable, Item: Hashable>: UITableViewDiffableDataSource<Section, Item> {
    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        (snapshot().sectionIdentifiers[section] as? CustomStringConvertible)?.description
    }
}
