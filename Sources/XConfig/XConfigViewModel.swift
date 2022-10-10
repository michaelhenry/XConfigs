import Foundation

struct XConfigViewModel {
    enum Section: Hashable {
        case main
        case group(String)
    }

    enum Item: Hashable {
        case toggle(ToggleModel)
        case textInput(TextInputModel)
        case optionSelection(OptionSelectionModel)
    }

    let sectionItemsModels: [SectionItemsModel<Section, Item>]

    init(useCase: XConfigUseCase, spec: XConfigSpec.Type) {
        let items = useCase.getConfigInfos(from: spec).compactMap { info -> Item? in
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
        sectionItemsModels = [.init(section: .main, items: items)]
    }
}