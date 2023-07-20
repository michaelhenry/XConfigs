import Combine
import CombineExt
import Foundation

@available(macOS 10.15, *)
@available(iOS 13.0, *)
struct OptionViewModel: ViewModelType {
    typealias Section = String?

    typealias Item = Choice

    struct Input {
        let reloadPublisher: AnyPublisher<Void, Never>
        let dismissPublisher: AnyPublisher<Void, Never>
        let selectItemPublisher: AnyPublisher<Item, Never>
    }

    struct Output {
        let title: AnyPublisher<String, Never>
        let sectionItemsModels: AnyPublisher<[SectionItemsModel<String?, Item>], Never>
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
            .init(arrayLiteral: .init(section: nil, items: model.choices))
        }

        let cancelAction = input.dismissPublisher.map { Action.cancel }
        let selectAction = input.selectItemPublisher.map(Action.select)

        let action = Publishers.Merge(cancelAction, selectAction)
        return .init(
            title: Just(model.key).eraseToAnyPublisher(),
            sectionItemsModels: sectionItemsFromReload.eraseToAnyPublisher(),
            action: action.eraseToAnyPublisher()
        )
    }
}
