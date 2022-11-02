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
        let title: AnyPublisher<String, Never>
        let sectionItemsModels: AnyPublisher<[SectionItemsModel<Section, Item>], Never>
        let action: AnyPublisher<Action, Never>
    }

    enum Action {
        case cancel
        case select(Item)
    }

    private let model: OptionSelectionModel

    init(model: OptionSelectionModel) {
        self.model = model
    }

    func transform(input: Input) -> Output {
        let sectionItemsFromReload = input.reloadPublisher.map { _ -> [SectionItemsModel<Section, Item>] in
            .init(arrayLiteral: .init(section: 0, items: model.choices.map(\.rawString)))
        }.eraseToAnyPublisher()

        let cancelAction = input.dismissPublisher.map { Action.cancel }
        let selectAction = input.selectItemPublisher.map(Action.select)

        let action = Publishers.Merge(cancelAction, selectAction).eraseToAnyPublisher()
        return .init(
            title: Just(model.key).eraseToAnyPublisher(),
            sectionItemsModels: sectionItemsFromReload,
            action: action
        )
    }
}
