import Foundation

struct ToggleModel: Hashable {
    let key: String
    let value: Bool
}

struct InputModel: Hashable {
    let key: String
    let value: String
}

struct OptionSelectionModel: Hashable {
    let key: String
    let value: String
    let choices: [String]
}

struct RemoteConfigViewModel {
    enum Section: Hashable {
        case main
        case group(String)
    }

    enum Item: Hashable {
        case toggle(ToggleModel)
        case textInput(InputModel)
        case optionSelection(OptionSelectionModel)
    }

    let sectionItemsModels: [SectionItemsModel<Section, Item>]

    init(spec: any RemoteConfigSpec.Type) {
        let instance = spec.init()
        let mirror = Mirror(reflecting: instance)

        let infos = mirror.children.compactMap { $0.value as? ExtractableConfigInformation }

        let items = infos.compactMap { info -> Item? in
            let key = info.extractedKey
            switch info.extractedValue {
            case let val as Bool:
                return .toggle(.init(key: key, value: val))
            case let val as any CaseIterable & RawStringRepresentable:
                return .optionSelection(.init(key: key, value: val.rawString, choices: val.allChoices))
            default:
                return .textInput(.init(key: key, value: info.extractedValue.rawString))
            }
        }
        sectionItemsModels = [.init(section: .main, items: items)]
    }
}
