import Combine
import CombineExt
import Foundation

public struct XConfigsViewModel: ViewModelType {
    enum Section: Hashable, CustomStringConvertible {
        case main
        case group(String)

        var description: String {
            switch self {
            case .main:
                return ""
            case let .group(name):
                return name
            }
        }
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
    }

    struct Output {
        let sectionItemsModels: AnyPublisher<[SectionItemsModel<Section, Item>], Never>
    }

    private let useCase: XConfigUseCase

    public init(useCase: XConfigUseCase = .shared) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {
        let update = input.updateValuePublisher.map { useCase.set(value: $0.value, for: $0.key) }
        let reload = input.reloadPublisher

        let configs = Publishers.Merge(update, reload)
            .map { _ in useCase.getConfigs() }
            .share(replay: 1)
            .eraseToAnyPublisher()

        let overrideConfig = input.overrideConfigPublisher

        let sectionItemsModels = Publishers.CombineLatest(configs, overrideConfig)
            .map { configs, isOverriden -> [SectionItemsModel<Section, Item>] in

                mapConfigInfosToSectionItemsModels(isOverriden: isOverriden, infos: configs)
            }
            .eraseToAnyPublisher()
        return .init(sectionItemsModels: sectionItemsModels)
    }

    // Transform [ConfigInfo] to [SectionItemModel]
    func mapConfigInfosToSectionItemsModels(isOverriden: Bool, infos: [ConfigInfo]) -> [SectionItemsModel<Section, Item>] {
        var sections = [SectionItemsModel<Section, Item>(section: .main, items: [
            .overrideConfig(isOverriden),
            .action("Reset"),
        ])]

        if isOverriden {
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
        }
        return sections
    }

    // Transform ConfigInfo to Item
    func mapConfigInfoToItem(_ info: ConfigInfo) -> Item? {
        let key = info.configKey
        switch info.configValue {
        case let val as Bool:
            return .toggle(.init(key: key, value: val))
        case let val as any CaseIterable & RawStringValueRepresentable:
            return .optionSelection(.init(key: key, value: val.rawString, choices: val.allChoices))
        default:
            return .textInput(.init(key: key, value: info.configValue.rawString))
        }
    }
}
