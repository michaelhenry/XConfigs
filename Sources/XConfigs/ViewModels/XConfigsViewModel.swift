import Foundation
import RxCocoa
import RxSwift

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
        case overrideConfig(title: String, value: Bool)
    }

    struct Input {
        let reloadPublisher: Observable<Void>
        let updateValuePublisher: Observable<KeyValue>
        let overrideConfigPublisher: Observable<Bool>
        let resetPublisher: Observable<Void>
        let selectItemPublisher: Observable<Item>
    }

    struct Output {
        let title: Driver<String>
        let sectionItemsModels: Driver<[SectionItemsModel<Section, Item>]>
        let action: Driver<Action>
    }

    enum Action: Hashable {
        case showResetConfirmation(String)
        case showTextInput(TextInputModel)
        case showOptionSelection(OptionSelectionModel)
    }

    private let useCase: XConfigUseCase

    init(useCase: XConfigUseCase = defaultConfigUseCase) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {
        let update = input.updateValuePublisher.map { useCase.set(value: $0.value, for: $0.key) }
        let reload = input.reloadPublisher
        let reset = input.resetPublisher.map { useCase.reset() }
        let overrideConfig = input.overrideConfigPublisher.map { val in useCase.isOverriden = val }
        let action = input.selectItemPublisher.compactMap { item -> Action? in
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
        }.asDriver(onErrorDriveWith: .empty())

        let configs = Observable.merge(update, reload, overrideConfig, reset)
            .map { _ in useCase.getConfigs() }
            .share(replay: 1)

        let sectionItemsModels = configs.compactMap(mapConfigInfosToSectionItemsModels)
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .empty())

        return .init(
            title: .just(NSLocalizedString("🛠Configs", comment: "")),
            sectionItemsModels: sectionItemsModels,
            action: action
        )
    }

    // Transform [ConfigInfo] to [SectionItemModel]
    func mapConfigInfosToSectionItemsModels(infos: [ConfigInfo]) -> [SectionItemsModel<Section, Item>] {
        var mainItems: [Item] = [.overrideConfig(title: "Override", value: useCase.isOverriden)]

        if useCase.isOverriden {
            mainItems.append(.actionButton(
                title: NSLocalizedString("Reset", comment: ""),
                action: .showResetConfirmation("Are you sure you want to reset these values?")
            ))
        }

        var sections = [SectionItemsModel<Section, Item>(section: .main, items: mainItems)]

        let groups = infos.reduce(into: [XConfigGroup: [Item]]()) { group, info in
            var items = group[info.group] ?? []
            if let item = mapConfigInfoToItem(info) {
                items.append(item)
            }
            group[info.group] = items
        }.sorted {
            $0.key.sort < $1.key.sort
        }

        sections.append(contentsOf: groups.map {
            SectionItemsModel<Section, Item>.init(section: .group($0.key.name), items: $0.value)
        })
        return sections
    }

    // Transform ConfigInfo to Item
    func mapConfigInfoToItem(_ info: ConfigInfo) -> Item? {
        let key = info.configKey
        switch info.configValue {
        case let val as Bool:
            return .toggle(.init(key: key, value: val))
        case let val as any CaseIterable & RawStringValueRepresentable:
            return .optionSelection(.init(
                key: key,
                value: (val as? CustomStringConvertible)?.description ?? val.rawString,
                choices: val.allChoices
            ))
        default:
            return .textInput(.init(key: key, value: info.configValue.rawString))
        }
    }
}

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
