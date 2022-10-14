import Combine
import CombineExt
import Foundation

public struct XConfigsViewModel: ViewModelType {
    enum Section: Hashable {
        case main
        case group(String)
    }

    enum Item: Hashable {
        case toggle(ToggleModel)
        case textInput(TextInputModel)
        case optionSelection(OptionSelectionModel)
    }

    struct Input {
        let reloadTrigger: AnyPublisher<Void, Never>
    }

    struct Output {
        let sectionItemsModels: AnyPublisher<[SectionItemsModel<Section, Item>], Never>
    }

    private let useCase: XConfigUseCase

    public init(useCase: XConfigUseCase = .shared) {
        self.useCase = useCase
    }

    func transform(input: Input) -> Output {
        let request = input.reloadTrigger
            .map { useCase.getConfigInfos() }
            .share(replay: 1)
            .eraseToAnyPublisher()

        let sectionItemsModels = request
            .compactMap(mapConfigInfosToSectionItemsModels)
            .eraseToAnyPublisher()
        return .init(sectionItemsModels: sectionItemsModels)
    }

    // Transform [ConfigInfo] to [SectionItemModel]
    func mapConfigInfosToSectionItemsModels(_ infos: [ConfigInfo]) -> [SectionItemsModel<Section, Item>] {
        .init(arrayLiteral: .init(section: .main, items: infos.compactMap(mapConfigInfoToItem)))
    }

    // Transform ConfigInfo to Item
    func mapConfigInfoToItem(_ info: ConfigInfo) -> Item? {
        let key = info.configKey
        switch info.configValue {
        case let val as Bool:
            return .toggle(.init(key: key, value: val))
        case let val as any CaseIterable & RawStringRepresentable:
            return .optionSelection(.init(key: key, value: val.rawString, choices: val.allChoices))
        default:
            return .textInput(.init(key: key, value: info.configValue.rawString))
        }
    }
}
