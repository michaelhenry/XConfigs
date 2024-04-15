import Combine
import CombineExt
import Foundation

@available(macOS 10.15, *)
@available(iOS 13.0, *)
struct XConfigsViewModel: ViewModelType {
    enum Section: Hashable {
        case main
        case group(String)
    }

    enum Item: Hashable {
        case toggle(ToggleModel)
        case textInput(TextInputModel)
        case optionSelection(OptionSelectionModel)
        case actionButton(title: String, action: Action)
        case inAppModification(title: String, value: Bool)
        case nameValue(name: String, value: String)
    }

    struct Input {
        let searchPublisher: AnyPublisher<String, Never>
        let reloadPublisher: AnyPublisher<Void, Never>
        let updateValuePublisher: AnyPublisher<KeyValue, Never>
        let overrideConfigPublisher: AnyPublisher<Bool, Never>
        let resetPublisher: AnyPublisher<Void, Never>
        let selectItemPublisher: AnyPublisher<Item, Never>
        let dismissPublisher: AnyPublisher<Void, Never>
    }

    struct Output {
        let title: AnyPublisher<String, Never>
        let searchPlaceholderTitle: AnyPublisher<String, Never>
        let sectionItemsModels: AnyPublisher<[SectionItemsModel<Section, Item>], Never>
        let action: AnyPublisher<Action, Never>
    }

    enum Action: Hashable {
        case showResetConfirmation(String)
        case showTextInput(TextInputModel)
        case showOptionSelection(OptionSelectionModel)
        case dismiss
    }

    private let useCase: XConfigUseCase

    init(useCase: XConfigUseCase = defaultConfigUseCase) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {
        let update = input.updateValuePublisher.map { useCase.set(value: $0.value, for: $0.key) }
        let reload = input.reloadPublisher
        let reset = input.resetPublisher.map { useCase.reset() }
        let isInAppModificationEnabled = input.overrideConfigPublisher.map { val in useCase.isInAppModificationEnabled = val }
        let selectionAction = input.selectItemPublisher.compactMap { item -> Action? in
            switch item {
            case let .optionSelection(model):
                return .showOptionSelection(model)
            case let .textInput(model):
                return .showTextInput(model)
            case let .actionButton(_, action):
                return action
            default:
                return nil
            }
        }

        let dismissAction = input.dismissPublisher.map { _ in Action.dismiss }

        let action = Publishers.Merge(dismissAction, selectionAction).eraseToAnyPublisher()

        let configs = Publishers.Merge4(update, reload, isInAppModificationEnabled, reset)
            .map { _ in useCase.getConfigs() }
            .share(replay: 1)

        let sectionItemsModels = configs
            .flatMapLatest { configs -> AnyPublisher<[SectionItemsModel<Section, Item>], Never> in
                input.searchPublisher.compactMap {
                    mapConfigInfosToSectionItemsModels(searchText: $0, infos: configs)
                }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        return .init(
            title: Just(NSLocalizedString("🛠Configs", comment: "")).eraseToAnyPublisher(),
            searchPlaceholderTitle: Just(NSLocalizedString("Search", comment: "Search placeholder")).eraseToAnyPublisher(),
            sectionItemsModels: sectionItemsModels,
            action: action
        )
    }

    // Transform [ConfigInfo] to [SectionItemModel]
    func mapConfigInfosToSectionItemsModels(searchText: String, infos: [ConfigInfo]) -> [SectionItemsModel<Section, Item>] {
        var mainItems: [Item] = [.inAppModification(
            title: NSLocalizedString("Enable In-app modification?", comment: ""),
            value: useCase.isInAppModificationEnabled
        )]

        if useCase.isInAppModificationEnabled {
            mainItems.append(.actionButton(
                title: NSLocalizedString("Reset", comment: ""),
                action: .showResetConfirmation("Are you sure you want to reset these values?")
            ))
        }

        var sections = [SectionItemsModel<Section, Item>(section: .main, items: mainItems)]

        let groups = infos
            .filter {
                searchText.isEmpty ? true : $0.configKey.range(of: searchText, options: .caseInsensitive) != nil || $0.displayName?.range(of: searchText, options: .caseInsensitive) != nil
            }
            .reduce(into: [XConfigGroup: [Item]]()) { group, info in
                var items = group[info.group] ?? []
                if let item = mapConfigInfoToItem(info) {
                    items.append(item)
                }
                group[info.group] = items
            }.sorted {
                $0.key.sort < $1.key.sort
            }

        sections.append(contentsOf: groups.map {
            SectionItemsModel<Section, Item>(section: .group($0.key.name), items: $0.value)
        })
        return sections
    }

    // Transform ConfigInfo to Item
    func mapConfigInfoToItem(_ info: ConfigInfo) -> Item? {
        guard !info.readonly else {
            var value = info.configValue.rawString
            if let val = info.configValue as? any CaseIterable & RawStringValueRepresentable {
                value = (val as? CustomStringConvertible)?.description ?? val.rawString
            }
            return .nameValue(name: info.displayName ?? info.configKey, value: value)
        }
        switch info.configValue {
        case let val as Bool:
            return .toggle(.init(key: info.configKey, value: val, displayName: info.displayName ?? info.configKey))
        case let val as any CaseIterable & RawStringValueRepresentable:
            return .optionSelection(.init(
                key: info.configKey,
                value: (val as? CustomStringConvertible)?.description ?? val.rawString,
                choices: val.allChoices,
                displayName: info.displayName ?? info.configKey
            ))
        default:
            return .textInput(.init(key: info.configKey, value: info.configValue.rawString, displayName: info.displayName ?? info.configKey))
        }
    }
}

@available(macOS 10.15, *)
@available(iOS 13.0, *)
extension XConfigsViewModel.Section: CustomStringConvertible {
    var description: String {
        switch self {
        case .main:
            return ""
        case let .group(name):
            return name
        }
    }
}
