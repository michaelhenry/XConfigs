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
    }

    struct Input {
        let reloadPublisher: AnyPublisher<Void, Never>
        let updateValuePublisher: AnyPublisher<KeyValue, Never>
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

        let sectionItemsModels = configs
            .compactMap(mapConfigInfosToSectionItemsModels)
            .eraseToAnyPublisher()
        return .init(sectionItemsModels: sectionItemsModels)
    }

    // Transform [ConfigInfo] to [SectionItemModel]
    func mapConfigInfosToSectionItemsModels(_ infos: [ConfigInfo]) -> [SectionItemsModel<Section, Item>] {
        let mainSection = SectionItemsModel<Section, Item>(section: .main, items: [
            .toggle(.init(key: "Enable override", value: true)),
            .textInput(.init(key: "Reset", value: "")),
        ])

        let groups = infos.reduce(into: [XConfigGroup: [Item]]()) { group, info in
            var items = group[info.group] ?? []
            if let item = mapConfigInfoToItem(info) {
                items.append(item)
            }
            group[info.group] = items
        }.sorted {
            $0.key.sort < $1.key.sort
        }

        let sections = groups.map {
            SectionItemsModel<Section, Item>.init(section: .group($0.key.name), items: $0.value)
        }

        return [mainSection] + sections
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
