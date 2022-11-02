import Combine
import CombineExt
import Foundation

struct XConfigsViewModel: ViewModelType {
    enum Section: Hashable {
        case main
        case group(String)
    }

    enum Item: Hashable {
        case toggle(ToggleModel)
        case textInput(TextInputModel)
        case optionSelection(OptionSelectionModel)
        case action(String)
        case overrideConfig(Bool)
    }

    struct Input {
        let reloadPublisher: AnyPublisher<Void, Never>
        let updateValuePublisher: AnyPublisher<KeyValue, Never>
        let overrideConfigPublisher: AnyPublisher<Bool, Never>
        let resetPublisher: AnyPublisher<Void, Never>
    }

    struct Output {
        let title: AnyPublisher<String, Never>
        let sectionItemsModels: AnyPublisher<[SectionItemsModel<Section, Item>], Never>
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

        let configs = Publishers.Merge4(update, reload, overrideConfig, reset)
            .map { _ in useCase.getConfigs() }
            .share(replay: 1)
            .eraseToAnyPublisher()

        let sectionItemsModels = configs.compactMap(mapConfigInfosToSectionItemsModels).eraseToAnyPublisher()

        return .init(
            title: Just("Configs").eraseToAnyPublisher(),
            sectionItemsModels: sectionItemsModels
        )
    }

    // Transform [ConfigInfo] to [SectionItemModel]
    func mapConfigInfosToSectionItemsModels(infos: [ConfigInfo]) -> [SectionItemsModel<Section, Item>] {
        var mainItems: [Item] = [.overrideConfig(useCase.isOverriden)]

        if useCase.isOverriden {
            mainItems.append(.action("Reset"))
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
                choices: val.allChoices))
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
