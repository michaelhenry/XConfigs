import Combine
import Foundation

struct OptionViewModel: ViewModelType {
    typealias Section = Int

    typealias Item = String

    struct Input {
        let reloadPublisher: AnyPublisher<Void, Never>
        let dismissPublisher: AnyPublisher<Void, Never>
        let selectItemPublisher: AnyPublisher<Item, Never>
    }

    struct Output {
        let sectionItemsModels: AnyPublisher<[SectionItemsModel<Section, Item>], Never>
        let action: AnyPublisher<Action, Never>
    }

    enum Action {
        case cancel
        case select(Item)
    }

    private let choices: [any RawStringValueRepresentable]
    private let selectedItem: (any RawStringValueRepresentable)?

    init(choices: [any RawStringValueRepresentable], selectedItem: (any RawStringValueRepresentable)?) {
        self.choices = choices
        self.selectedItem = selectedItem
    }

    func transform(input: Input) -> Output {
        let sectionItemsFromReload = input.reloadPublisher.map { _ -> [SectionItemsModel<Section, Item>] in
            .init(arrayLiteral: .init(section: 0, items: choices.map(\.rawString)))
        }.eraseToAnyPublisher()

        let cancelAction = input.dismissPublisher.map { Action.cancel }
        let selectAction = input.selectItemPublisher.map(Action.select)

        let action = Publishers.Merge(cancelAction, selectAction).eraseToAnyPublisher()
        return .init(
            sectionItemsModels: sectionItemsFromReload,
            action: action
        )
    }
}
